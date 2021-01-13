#!/usr/bin/env raku

use API::Discord;
use Mimi::Configuration;
use Mimi::Documentation;
use Mimi::Team;
use Mimi::Team::Jaccard;

my $configuration = Mimi::Configuration.new;
my %config = $configuration.generate;

my $discord = API::Discord.new(:token(%config<discord-token>));

sub MAIN() {
    $discord.connect;
    await $discord.ready;

    react {
        whenever $discord.messages -> $message {
            my $c = $message.content;
            given $c {
                when / ^ '!d' [ oc s? ]? >> / {
                    my ($command, $query) = $c.split(/ \s+ /);
                    if $query {
                        if %Mimi::Documentation::documentation{$query}:exists {
                            my %payload = construct-doc-embed(:topic($query));
                            $message.channel.send-message(embed => %payload);
                        } else {
                            $message.channel.send-message("I couldn't find any documentation relating to `$query`, sorry.");
                        }
                    } else {
                        $message.channel.send-message('https://docs.mybb.com/');
                    }
                }
                when / ^ '!t' [ eam ]? >> / {
                    my ($command, $query) = $c.split(/ \s+ /, 2);
                    if $query {
                        if %Mimi::Team::team{$query}:exists {
                            my %payload = construct-team-member-embed(:username($query));
                            $message.channel.send-message(embed => %payload);
                        } else {
                            my %m = closest-match(:$query, :team(%Mimi::Team::team));
                            my $s = %m.pairs.head;
                            if $s.value > 0.4 {
                                my %payload = construct-team-member-embed(:username($s.key));
                                $message.channel.send-message(embed => %payload);
                            } else{
                                $message.channel.send-message("I couldn't find any record of a team member under the name `$query`, sorry.");
                            }
                        }
                    }
                }
            }
        }
    }
}
