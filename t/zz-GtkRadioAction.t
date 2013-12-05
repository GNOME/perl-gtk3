#!/usr/bin/perl

# Based on Gtk2/t/GtkRadioAction.t

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;

plan tests => 14;

my @actions = (Gtk3::RadioAction->new ('one', undef, undef, undef, 0));
isa_ok ($actions[$#actions], 'Gtk3::RadioAction');
my $i = 1;
foreach (qw(two three four five)) {
	push @actions, Gtk3::RadioAction->new ($_, undef, undef, undef, $i++);
        $actions[$#actions]->set (group => $actions[$#actions-1]);
	isa_ok ($actions[$#actions], 'Gtk3::RadioAction');
}
my $group = $actions[0]->get_group;
push @actions, Gtk3::RadioAction->new ('six', undef, undef, undef, 5);
isa_ok ($actions[$#actions], 'Gtk3::RadioAction');
$actions[$#actions]->set_group ($group);
{
  # get_group() no memory leaks in arrayref return and array items
  my $x = Gtk3::RadioAction->new ('x', undef, undef, undef, 0);
  my $y = Gtk3::RadioAction->new ('y', undef, undef, undef, 0);
  $y->set_group($x);
  my $aref = $x->get_group;
  is_deeply($aref, [$x,$y]);
  require Scalar::Util;
  Scalar::Util::weaken ($aref);
  is ($aref, undef, 'get_group() array destroyed by weakening');
  Scalar::Util::weaken ($x);
  is ($x, undef, 'get_group() item x destroyed by weakening');
  Scalar::Util::weaken ($y);
  is ($y, undef, 'get_group() item y destroyed by weakening');
}

is ($actions[0]->get_current_value, 0);
$actions[0]->set_current_value (3);
is ($actions[0]->get_current_value, 3);

$actions[3]->set_active (Glib::TRUE);
ok (!$actions[0]->get_active);
ok ($actions[3]->get_active);
