# Adapted from some random irssi module, lol!

use strict;
use vars qw($VERSION %IRSSI);

use Irssi qw(command_bind signal_add);
use IO::File;
$VERSION = '0.00.000.0.000000000.000800000000000001.6.000.3';
%IRSSI = (
	author		=> 'Ryan Finnie',
	contact		=> 'ryan@finnie.org',
	name		=> 'lolz',
	descriotion	=> 'No, this is not Hovercar, lol.',
	license		=> 'GPL',
);

sub own_lolz {
	my ($server, $msg, $target) = @_;
	lolz($server, $msg, "", $target);
}

sub public_lolz {
	my ($server, $msg, $nick, $address, $target) = @_;
	lolz($server, $msg, $nick, $target);
}

sub lolz($server, $msg, $nick, $target) {
	my ($server, $msg, $nick, $target) = @_;
	if(($target eq "#xtest") && ($msg =~ /(^|\W)lol(\W|$)/)) {
		$server->command('msg '.$target.' lolz');
	}		
	if(($target eq "#xtest") && ($msg =~ /(^|\W)rofl(\W|$)/)) {
		$server->command('msg '.$target.' roflz');
	}		
}

signal_add("message public", "public_lolz");
#signal_add("message own_public", "own_lolz");
