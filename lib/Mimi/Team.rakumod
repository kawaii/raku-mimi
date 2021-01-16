unit module Mimi::Team;

use Mimi::Configuration;
use Mimi::Team::Jaccard;

use Cache::Async;
use Cro::HTTP::Client;
use YAMLish;

my $configuration = Mimi::Configuration.new;
my %config = $configuration.generate;

my %roles = %config<discord-team-roles>;
our %team is export = fetch-team;

sub fetch-team {
    my $request = await Cro::HTTP::Client.get(%config<team-yaml-url>);
    return my %team = (gather for load-yaml(await $request.body-text)[] {take Pair.new(.<username>, $_); }).Hash;
}

sub avatar-url(:%member) {
    my Str $url;

    if %member<github> {
        $url = "https://github.com/{ %member<github> }.png";
    } else {
        $url = %config<site-base-url> ~ '/assets/images/logomark-white-on-blue-400h.png';
    }

    return $url;
}

sub member-fields(:%member) {
    my @fields;

    sub role-map(@roles) {
        @roles.map({%config<discord-team-roles>{$_}}).map({"<@&{$_}>"}).join(', ')
    }

    if %member<github> { @fields.append(${ name => 'GitHub', value => "https://github.com/{%member<github>}", inline => True }) }
    if %member<twitter> { @fields.append(${ name => 'Twitter', value => "https://twitter.com/{%member<twitter>}", inline => True }) }
    if %member<pgp_fingerprint> { @fields.append(${ name => 'PGP Fingerprint', value => "[{ %member<pgp_fingerprint> }]({ %member<pgp_link> })" }) }

    if %member<role_memberships><lead> {
        @fields.append(${ name => 'Team Leader', value => ~role-map(%member<role_memberships><lead>), inline => True })
    }
    if %member<role_memberships><standard> {
        @fields.append(${ name => 'Team Member', value => ~role-map(%member<role_memberships><standard>), inline => True })
    }

    return @fields;
}

sub member-flag($locale) {
    return $locale.comb.map({
        uniparse("Regional Indicator Symbol Letter $_")
    }).join;
}

sub construct-team-member-embed(:$username) is export {
    my %member = %team{$username};
    my @fields = member-fields(:%member);
    my %payload = author => {
                      icon_url => %config<site-base-url> ~ '/assets/images/logomark-white-on-blue-400h.png',
                      name => %member<username>,
                      url => %config<community-base-url> ~ "/user-{ %member<uid> }.html",
                  },
                  thumbnail => {
                      url => avatar-url(:%member),
                  },
                  color => 32720,
                  :@fields,
                  description => (%member<name> || 'MyBB Team Member') ~ (%member<locale> ?? ' ' ~ ~member-flag(%member<locale>) !! '');
    ;
    return %payload;
}
