unit module Mimi::Documentation;

use Mimi::Configuration;

my $configuration = Mimi::Configuration.new;
my %config = $configuration.generate;

our %documentation is export =
        'cache' => [
            { name => 'Cache Handlers', value => '/1.8/administration/cache-handlers/' },
            { name => 'Datacache', value => '/1.8/development/datacache/' },
        ],
        'cookies' => [
            { name => 'Cookies', value => '/1.8/development/cookies/' },
        ],
        'install' => [
            { name => 'Install', value => '/1.8/install/' },
        ],
        'security' => [
            { name => 'Using Two-Factor Authentication with MyBB', value => '/1.8/administration/security/2fa/' },
            { name => 'File Permissons', value => '/1.8/administration/security/file-permissions/' },
            { name => 'Setting up HTTPS', value => '/1.8/administration/security/https/' },
            { name => 'MyBB Security Guide', value => '/1.8/administration/security/protection/' },
            { name => 'Security Incident Response & Recovery', value => '/1.8/administration/security/recovery/' },
        ],
        'spam' => [
            { name => 'Spam', value => '/1.8/administration/spam/' },
        ],
;

sub construct-doc-embed(:$topic) is export {
    my @fields = %documentation{$topic}.map( { %( name => $^a<name>, value => %config<doc-base-url> ~ $^a<value> ) } );
    my %payload = author => {
                    icon_url => %config<site-base-url> ~ '/assets/images/logomark-white-on-blue-400h.png',
                    name => "{$topic.tc} Documentation",
                    url => "%config<doc-base-url>",
                  },
                  color => 32720,
                  description => "Hi! Here's all the documentation we have relating to `$topic`;",
                  :@fields,
    ;
    return %payload;
}
