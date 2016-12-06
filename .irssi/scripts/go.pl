use strict;
use vars qw($VERSION %IRSSI);
use Irssi;
use Irssi::Irc;

# Usage:
# /script load go.pl
# If you are in #irssi you can type /go #irssi or /go irssi or even /go ir ...
# also try /go ir<tab> and /go  <tab> (that's two spaces)

# 20071002 - hacked by zigdon to work with window items, prefer exact matches, and retry
# from a rotating list

$VERSION = '1.00';

%IRSSI = (
    authors     => 'nohar',
    contact     => 'nohar@freenode',
    name        => 'go to window',
    description =>
'Implements /go command that activates a window given a name/partial name. It features a nice completion.',
    license => 'GPLv2 or later',
    changed => '08-17-04'
);

sub signal_complete_go {
    my ( $complist, $window, $word, $linestart, $want_space ) = @_;
    my $channel = $window->get_active_name();
    my $k       = Irssi::parse_special('$k');

    return unless ( $linestart =~ /^\Q${k}\Ego/i );

    @$complist = map {$_->[1] ? $_->[1]{visible_name} : $_->[0]->get_active_name} &get_list($word);
    Irssi::signal_stop();
}

sub cmd_go {
    my ( $word, $server, $witem ) = @_;

    #foreach my $w (Irssi::windows) {
    #	my $name = $w->get_active_name();
    #	if ($name =~ /^#?\Q${chan}\E/) {
    #		$w->set_active();
    #		return;
    #	}
    #}

    my $c = 0;
    my $win_name;
    if    (ref $witem eq 'Irssi::Irc::Channel') { $win_name = $witem->{name} } 
    elsif (ref $witem eq 'Irssi::Irc::Query')   { $win_name = $witem->{name} } 
    elsif (    $witem eq '0'                  ) { $win_name = "status"       }
    else  {die "unknown item type"};
    # print "win_name = $win_name";

    my @opts = &get_list($word, $win_name);
    # print "opts: ", join(", ", map {$_->[1]{visible_name}} @opts);
    # print "witem = $witem";


    if (grep { $win_name eq $_->[1]{visible_name} } @opts) {
      # print "rotating opts:\n";
        until ($opts[-1][1]{visible_name} eq $win_name or $c++ > @opts) {
          # print "$c: ", join(", ", map {$_->[1]{visible_name}} @opts);
            push @opts, shift @opts; 
        }
    }
    # print "$c: ", join(", ", map {$_->[1]{visible_name}} @opts);

    $opts[0][0]->set_active() if $opts[0][0];
    $opts[0][1]->set_active() if $opts[0][1];
    return;

}

sub get_list {
    my $word = shift;
    my $current  = shift || "";

    $word =~ s/^\s+|\s+$//;

    my @list = ([], []);
    for my $exact (qw/1 0/) {
        foreach my $w (Irssi::windows) {

          # print "window found: ", $w->get_active_name;
            foreach my $i ( $w->items() ) {
              # print "item found: ", $i->{visible_name};
                next if lc $i->{visible_name} eq lc $current;
                next
                  unless not $word or 
                        ($exact ? lc $i->{visible_name} eq lc $word
                                : $i->{visible_name} =~ /\Q$word\E/i);

                # print "item added";
                push @{$list[$exact]}, [$w, $i];
            }
        }
    }

    return @{$list[1]},
           sort {$a->[0]->get_active_name cmp $b->[0]->get_active_name ||
                 $a->[1]->{visible_name}  cmp $b->[1]->{visible_name} }
              @{$list[0]};
}

Irssi::command_bind( "go", "cmd_go" );
Irssi::signal_add_first( 'complete word', 'signal_complete_go' );

