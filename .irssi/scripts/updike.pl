use strict;
use Irssi;
use Irssi::Irc;

use vars qw($VERSION %IRSSI);

my $VERSION = "2.42";

my %IRSSI = (authors => 'Sean Neakums <sneakums@zork.net>',
	     name => 'updike',
	     description => 'export uptime to IRC using common uptime interchange format',
	     created => 'Thu, 25 Dec 2003 15:38:04 +0000',
	     license => 'BSD w/o advertising clause');

sub ctcp_updike {
	my ($server, $msg, $nick, $address, $target) = @_;
	Irssi::signal_emit('message irc ctcp', $server, 'UPDIKE', $msg, $nick, $address, $target);
	open(UPTIME, "/proc/uptime");
	my $uptime = <UPTIME>;
	close(UPTIME);
	my @foo = split(/\./, $uptime);
	my $days = $foo[0] / 86400;
	$server->send_raw("NOTICE $nick :\001UPDIKE 8" . ("=" x $days) . "D\001");
}

Irssi::ctcp_register("UPDIKE");
Irssi::signal_add_last("ctcp msg updike", "ctcp_updike");
