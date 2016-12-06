#!/usr/bin/perl -w

# USAGE:
#   /BRAZIL <text>
# OR:
#   brazil:<text><tab>
# OR:
#   brazil<tab>

# based directly off of wired.pl, which is based directly off of rainbow.pl.
# erik stambaugh sucks.  I suck.

use strict;
use vars qw($VERSION %IRSSI);
use Encode;

$VERSION = "1.0";
%IRSSI = (
    authors     => 'Nick Moffitt',
    contact     => 'nick@zork.net',
    name        => 'Brazil',
    description => 'You america.pl make beter by Ramon!',
    license     => 'GPL2',
    url         => 'http://www.finnie.org/software/irssi/',
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

sub make_brazil {
    my ($string) = @_;
    my $color = '8,3';
    my $starcolor = '0,12';
    my $newstr = "\003$color" . "\x{2666}";
    my $is_red = 1;

    my $char;
    my $c = 0;
    foreach $char (split(//, decode_utf8($string))) {
	if($c > 0) {
		$newstr .= "\003$starcolor" . "\x{2B51}" . "\003$color";
	}
        $newstr .= uc($char);
        $c++;
    }

    $newstr =~ s/ /\x{2666}/g;
    $newstr .= "\x{2666}" . "\017";
    return $newstr;
}

sub brazil {
    my ($text, $server, $dest) = @_;

    if(!$text) { $text = "BRAZIL"; }
    if (!$server || !$server->{connected}) {
        Irssi::print("Not connected to server");
        return;
    }

    return unless $dest;

    if ($dest->{type} eq "CHANNEL" || $dest->{type} eq "QUERY") {
        $dest->command(encode_utf8("/msg " . decode_utf8($dest->{name}) . " " . make_brazil($text)));
    }
}


signal_add_last 'complete word' => sub {
    my ($complist, $window, $word, $linestart, $want_space) = @_;
    
    if($word =~ /^brazil:(.*?)$/) {
      my($text) = $1;
      if(!$text) { $text = "BRAZIL"; }
      push @$complist, make_brazil($text);
    }
    if($word eq "brazil") {
      my($text) = "BRAZIL";
      push @$complist, make_brazil($text);
    }
};

Irssi::command_bind("brazil", "brazil");
