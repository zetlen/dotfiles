#!/usr/bin/perl -w

# USAGE:
#   /AMERICA <text>
# OR:
#   america:<text><tab>
# OR:
#   america<tab>

# based directly off of wired.pl, which is based directly off of rainbow.pl.
# erik stambaugh sucks.  I suck.

use strict;
use vars qw($VERSION %IRSSI);
use Encode;

$VERSION = "1.1";
%IRSSI = (
    authors     => 'Ryan Finnie',
    contact     => 'ryan@finnie.org',
    name        => 'America',
    description => 'Makes text look so goddamn patriotic!!!',
    license     => 'GPL2',
    url         => 'http://www.finnie.org/',
);

use Irssi qw/signal_add_last/;
use Irssi::Irc;

# 0:white
# 1:black
# 2:blue
# 3:green
# 4:l-red
# 5:red
# 6:magenta
# 7:yellow
# 8:l-yellow
# 9:l-green
# 10:cyan
# 11:l-cyan
# 12:l-blue
# 13:l-magenta
# 14:darkgrey
# 15:lightgrey
my @colors = ('0', '4', '6', '7', '8', '9', '10', '11', '12', '13', '15' );

sub make_america {
    my ($string) = @_;
    my $color = 0;
    my $newstr = "\003$color" . "*";
    my $is_red = 1;

    my $char;
    my $c = 0;
    foreach $char (split(//, decode_utf8($string))) {
        $color = ($is_red ? 4 : 12);
        $newstr .= "\003$color" . uc($char);
        $color = 0;
        $newstr .= "\003$color" . "*";
        $is_red = ($is_red ? 0 : 1);
        $c++;
    }

    $newstr .= "\017";
    return $newstr;
}

sub america {
    my ($text, $server, $dest) = @_;

    if(!$text) { $text = "AMERICA"; }
    if (!$server || !$server->{connected}) {
        Irssi::print("Not connected to server");
        return;
    }

    return unless $dest;

    if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
        $dest->command("/msg " . decode_utf8($dest->{name}) . " " . make_america($text));
    }
}


signal_add_last 'complete word' => sub {
    my ($complist, $window, $word, $linestart, $want_space) = @_;
    
    if($word =~ /^america:(.*?)$/) {
      my($text) = $1;
      if(!$text) { $text = "AMERICA"; }
      push @$complist, make_america($text);
    }
    if($word eq "america") {
      my($text) = "AMERICA";
      push @$complist, make_america($text);
    }
};

Irssi::command_bind("america", "america");
