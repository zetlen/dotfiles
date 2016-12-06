use strict;
use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);

my $VERSION = "2.42";

my %IRSSI = (authors => 'Sean Neakums <sneakums@zork.net>',
             name => 'dongs',
             description => 'w/e',
             created => 'Fri, 26 Dec 2003 03:27:58 +0000',
             license => 'BSD w/o advertising clause');

sub ctcp_dongs {
        my ($server, $msg, $nick, $address, $target) = @_;
        Irssi::signal_emit('message irc ctcp', $server, 'DONGS', $msg, $nick, $address, $target);
        $server->send_raw("NOTICE $nick :Welcome to Mackertosh.");
}

Irssi::ctcp_register("DONGS");
Irssi::signal_add_last("ctcp msg dongs", "ctcp_dongs");

