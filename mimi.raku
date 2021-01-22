#!/usr/bin/env raku

use API::Discord;
use Mimi::Configuration;
use Mimi::Documentation;
use Mimi::Help;
use Mimi::Team;
use Mimi::Team::Jaccard;

my $configuration = Mimi::Configuration.new;
my %config = $configuration.generate;

my $discord = API::Discord.new(:token(%config<discord-token>));

sub MAIN() {
    $discord.connect;
    await $discord.ready;

    my $start = DateTime.now;

    react {
        whenever $discord.messages -> $message {
            my $c = $message.content;
            given $c {
                when / ^ '!d' [ oc s? ]? >> / {
                    my ($command, $query) = $c.split(/ \s+ /);
                    if $query {
                        if $query eq 'list' {
                            my @list = %Mimi::Documentation::documentation.keys;
                            $message.channel.send-message("`@list.join("`, `")`");
                        } elsif %Mimi::Documentation::documentation{$query}:exists {
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
                when / ^ '!help' $ / {
                    $message.channel.send-message(embed => %Mimi::Help::help);
                }
                when / ^ '!uptime' $ / {
                    my $uptime = DateTime.now - $start;
                    my ($second, $minute, $hour, $day) = $uptime.round.polymod(60, 60, 24, 24);
                    my $duration = (:$day, :$hour, :$minute, :$second).toggle(:off, *.value > 0).map({
                        "{.value} {.key ~ ('s' if .value ≠ 1)}"
                    }).join(', ');
                    $message.channel.send-message("I've been online for $duration this session.");
                }
            }
        }
    }
}
