#!/usr/bin/perl -w

# USAGE:
#
# /WIRED <text>
# OR:
#   wired:<text><tab>
# OR:
#   wired<tab>

# based directly off of rainbow.pl.  I suck.
# ☃☃☃ UTF-8 support and tab-inserts added by fo0bar ☃☃☃

use strict;
use vars qw($VERSION %IRSSI);
use Encode;

$VERSION = "1.5";
%IRSSI = (
    authors     => 'erik stambaugh',
    contact     => 'erik@dasbistro.com',
    name        => 'wired',
    description => 'makes text look like the cover of a stupid magazine',
    license     => 'GPL2 or later',
    url         => 'http://www.erikstambaugh.com/',
);

use Irssi;
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

sub make_wired {
    my ($string) = @_;
    my $last = 255;
    my $color = int(rand(scalar(@colors)));
    my $newstr = "\002\003" . sprintf("%02d", $colors[$color]);
    my $char;

    my $is_reverse = 0;

    foreach $char (split(//, decode_utf8($string))) {
        if ($char eq ' ') {
            if ($is_reverse) {
                $newstr .= "\026";
                $is_reverse = 0;
            }
            $newstr .= "    ";
        } else {
            $newstr .= "\026 ";
            $is_reverse = ($is_reverse?0:1);
            $newstr .=  uc($char) . " ";
        }
    }

    $newstr .= "\017";
    return $newstr;
}

sub wired {
    my ($text, $server, $dest) = @_;

    if (!$server || !$server->{connected}) {
        Irssi::print("Not connected to server");
        return;
    }

    return unless $dest;

    if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
        $dest->command("/msg " . decode_utf8($dest->{name}) . " " . make_wired($text));
    }
}

Irssi::signal_add_last 'complete word' => sub {
    my ($complist, $window, $word, $linestart, $want_space) = @_;
    
    if($word =~ /^wired:(.*?)$/) {
      my($text) = $1;
      if(!$text) { $text = "WIRED"; }
      push @$complist, make_wired($text);
    }
    if($word eq "wired") {
      my($text) = "WIRED";
      push @$complist, make_wired($text);
    }
};

Irssi::command_bind("wired", "wired");
