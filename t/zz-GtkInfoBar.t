#!/usr/bin/perl
#
# Originally copied from Gtk2/t/GtkInfoBar.t
#

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;

plan tests => 15;

ok (my $win = Gtk3::Window->new ('toplevel'));

my $infobar = Gtk3::InfoBar->new;
isa_ok ($infobar, 'Gtk3::InfoBar', 'new');
$win->add ($infobar);

isa_ok ($infobar->get_action_area, 'Gtk3::Widget', 'get_action_area');
isa_ok ($infobar->get_content_area, 'Gtk3::Widget', 'get_content_area');

isa_ok ($infobar->add_button (test3 => 3), 'Gtk3::Widget', 'add_button');
is (button_count ($infobar), 1, 'add_button count');
$infobar->add_buttons (test4 => 4, test5 => 5);
is (button_count ($infobar), 3, 'add_buttons');

my $button = Gtk3::Button->new ('action_widget');
$infobar->add_action_widget ($button, 6);
is (button_count ($infobar), 4, 'add_action_widget');

my $infobar2 = Gtk3::InfoBar->new(
	'gtk-ok' => 'ok', 'test2' => 2,
);
isa_ok ($infobar2, 'Gtk3::InfoBar', 'new_with_buttons');
is (button_count ($infobar2), 2, 'new_with_buttons buttons count');

$infobar->set_response_sensitive (6, Glib::FALSE);
is ($button->is_sensitive, Glib::FALSE, 'set_response_sensitive');

$infobar->set_message_type ('error');
is ($infobar->get_message_type, 'error', '[gs]et_message_type');

$infobar->set_default_response (4);
ok (1, 'set_default_response');

SKIP: {
  skip 'Need generic signal marshaller', 2
    unless check_gi_version (1, 33, 10);

  $infobar->signal_connect (response => sub {
    my ($infobar,$response) = @_;
    my $expected = $infobar->{expected_response};
    ok ($response eq $expected, "response '$expected'");
    1;
  });
  $infobar->response ($infobar->{expected_response} = 5);
  $infobar->response ($infobar->{expected_response} = 'ok');
}

sub button_count {
  my @b = $_[0]->get_action_area->get_children;
  return scalar @b;
}

__END__

Copyright (C) 2003-2013 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.
