#!/usr/bin/perl -w

# USAGE:
#   /COMMUNISM <text>
# OR:
#   communism:<text><tab>
# OR:
#   communism<tab>

# based directly off of brazil.pl, which is based on wired.pl, which is based
# directly off of rainbow.pl.
# erik stambaugh sucks.  I suck.  We all suck

use strict;
use vars qw($VERSION %IRSSI);
use Encode;

$VERSION = "1.0";
%IRSSI = (
    authors     => 'Jonas Haggqvist',
    contact     => 'rasher@rasher.dk',
    name        => 'communism',
    description => 'You america.pl make beter by Ramon!',
    license     => 'GPL2',
    url         => 'http://www.rasher.dk/pub/irssi/',
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

sub make_communism {
    my ($string) = @_;
    my $color = '8,4';
    my $newstr = "\003$color" . "\x{262D} ";
Irssi::print($newstr);
    my $is_red = 1;

    my $char;
    my $c = 0;
    foreach $char (split(//, decode_utf8($string))) {
	if($c > 0) {
		$newstr .= "\x{2B51}";
	}
        $newstr .= uc($char);
        $c++;
    }

    $newstr =~ s/\x{2B51} \x{2B51}/ /g;
    $newstr .= " \x{262D}" . "\017";
    return $newstr;
}

sub communism {
    my ($text, $server, $dest) = @_;

    if(!$text) { $text = "COMMUNISM"; }
    if (!$server || !$server->{connected}) {
        Irssi::print("Not connected to server");
        return;
    }

    return unless $dest;

    if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
        $dest->command(encode_utf8("/msg " . decode_utf8($dest->{name}) . " " . make_communism($text)));
    }
}


signal_add_last 'complete word' => sub {
    my ($complist, $window, $word, $linestart, $want_space) = @_;
    
    if($word =~ /^communism:(.*?)$/) {
      my($text) = $1;
      if(!$text) { $text = "COMMUNISM"; }
      push @$complist, make_communism($text);
    }
    if($word eq "communism") {
      my($text) = "COMMUNISM";
      push @$complist, make_communism($text);
    }
};

Irssi::command_bind("communism", "communism");
