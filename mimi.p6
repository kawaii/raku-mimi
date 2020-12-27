#!/usr/bin/env raku

use API::Discord;
use Mimi::Configuration;

my $configuration = Mimi::Configuration.new;
my %config = $configuration.generate;

my %documentation =
        'cache' => [
            'https://docs.mybb.com/1.8/administration/cache-handlers/',
            'https://docs.mybb.com/1.8/development/datacache/'
        ],
        'cookies' => ['https://docs.mybb.com/1.8/development/cookies/'],
        'install' => ['https://docs.mybb.com/1.8/install/'],
        'security' => [
            'https://docs.mybb.com/1.8/administration/security/2fa/',
            'https://docs.mybb.com/1.8/administration/security/file-permissions/',
            'https://docs.mybb.com/1.8/administration/security/https/',
            'https://docs.mybb.com/1.8/administration/security/protection/',
            'https://docs.mybb.com/1.8/administration/security/recovery/'
        ],
        'spam' => ['https://docs.mybb.com/1.8/administration/spam/'],
;

sub MAIN() {
    my $discord = API::Discord.new(:token(%config<discord-token>));

    $discord.connect;
    await $discord.ready;

    react {
        whenever $discord.messages -> $message {
            my $c = $message.content;
            given $c {
                when s/^'!doc'// {
                    my ($command, $arg) = $message.content.split(/ \s+ /);
                    if $command eq "!docs?" and $arg {
                        if %documentation{$arg}:exists {
                            my @docs = %documentation{$arg};
                            $message.channel.send-message(~@docs);
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

