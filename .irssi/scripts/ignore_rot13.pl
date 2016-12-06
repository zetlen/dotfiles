#!/usr/bin/perl

use strict;
use Irssi;

use vars qw($VERSION %IRSSI);

$VERSION = "242.1";
%IRSSI = (
	authors		=> 'Ryan Finnie',
	name		=> 'ignore_rot13',
	description	=> 'Show ignored messages, but in ROT13',
	license		=> 'GPL2',
);

Irssi::theme_register([
  'ign_public',  '[IGNORE] {pubmsgnick $2 {pubnick $0}}' . "\02\03" . '01,01' . '$1' . "\03\02",
  'ign_private', '[IGNORE] {pubmsgnick $2 {pubnick $0}}' . "\02\03" . '01,01' . '$1' . "\03\02",
  'ign_action',  '[IGNORE] {pubaction $0}' . "\02\03" . '01,01' . '$1' . "\03\02"
]);

sub rot13 {
  my($t) = $_[0];
  $t =~ y/A-Za-z/N-ZA-Mn-za-m/;
  return($t);
}

sub handle_msg_public {
  my ($srv, $msg, $nick, $addr, $dst) = @_;
  if($srv->ignore_check($nick, $addr, $dst, $msg, MSGLEVEL_PUBLIC)) {
    $srv->printformat($dst, MSGLEVEL_PUBLIC, "ign_public", $nick, rot13($msg));
  }
}

sub handle_msg_private {
  my ($srv, $msg, $nick, $addr, $dst) = @_;
  if($srv->ignore_check($nick, $addr, $dst, $msg, MSGLEVEL_MSGS)) {
    $srv->printformat($dst, MSGLEVEL_MSGS, "ign_private", $nick, rot13($msg));
  }
}

sub handle_action {
  my ($srv, $msg, $nick, $addr, $dst) = @_;
  if($srv->ignore_check($nick, $addr, $dst, $msg, MSGLEVEL_ACTIONS)) {
    $srv->printformat($dst, MSGLEVEL_ACTIONS, "ign_action", $nick, rot13($msg));
  }
}

Irssi::signal_add_first("message public", "handle_msg_public");
Irssi::signal_add_first("message private", "handle_msg_private");
Irssi::signal_add_first("ctcp action", "handle_action");
