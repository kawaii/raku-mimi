#!/usr/bin/env raku

use API::Discord;
use Mimi::Configuration;
use Mimi::Documentation;

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
                    my ($command, $arg) = $c.split(/ \s+ /);
                    if $arg {
                        if %Mimi::Documentation::documentation{$arg}:exists {
                            my %payload = construct-doc-embed(:topic($arg));
                            $message.channel.send-message(embed => %payload);
                        } else {
                            $message.channel.send-message("I couldn't find any documentation relating to `$arg`, sorry.");
                        }
                    } else {
                        $message.channel.send-message('https://docs.mybb.com/');
                    }
                }
            }
        }
    }
}
