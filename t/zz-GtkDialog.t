#!/usr/bin/env perl
#
# Based on Gtk2/t/GtkDialog.t
#
BEGIN { require './t/inc/setup.pl' };

use strict;
use warnings;

plan tests => 15;

my $win = Gtk3::Window->new ('toplevel');

# a constructor-made dialog, run
my $d1 = Gtk3::Dialog->new ('Test Dialog', $win,
                            [qw/destroy-with-parent/],
                           'gtk-cancel', 2, 'gtk-quit', 3);
my $btn1 = $d1->add_button ('Another', 4);
Glib::Idle->add (sub { $btn1->clicked; 0; });
is ($d1->run, 4);
$d1->hide;

# a hand-made dialog, run
my $d2 = Gtk3::Dialog->new;
$d2->add_button ('First Button', 0);
my $btn2 = $d2->add_button ('gtk-ok', 1);
$d2->add_buttons ('gtk-cancel', 2, 'gtk-quit', 3, 'Last Button', 4);
$d2->add_action_widget (Gtk3::Button->new('Uhh'), 'help');
$d2->set_default_response ('cancel');
$d2->set_response_sensitive (4, Glib::TRUE);
$d2->signal_connect (response => sub { is ($_[1], 1); 1; });
Glib::Idle->add (sub { $btn2->clicked; 0; });
is ($d2->run, 1);
$d2->hide;

# a constructor-made dialog, show
my $d3 = Gtk3::Dialog->new_with_buttons ('Test Dialog', $win,
                                         [qw/destroy-with-parent/],
                                         'gtk-ok', 22, 'gtk-quit', 33);
my $btn3 = $d3->add_button('Another', 44);
my $btn4 = $d3->add_button('Help', 'help');
$d3->set_response_sensitive ('help', Glib::TRUE);
is ($d3->get_response_for_widget ($btn3), 44);
is ($d3->get_response_for_widget ($btn4), 'help');
is ($d3->get_widget_for_response (44), $btn3);
is ($d3->get_widget_for_response ('help'), $btn4);
$d3->get_content_area->pack_start (Gtk3::Label->new ('This is just a test.'), 0, 0, 0);
$d3->get_action_area->pack_start (Gtk3::Label->new ('<- Actions'), 0, 0, 0);
$d3->signal_connect (response => sub { is ($_[1], 44); 1; });
$btn3->clicked;

# make sure that known response types are converted to strings for the reponse
# signal of Gtk3::Dialog and its ancestors
SKIP: {
  skip 'Need generic signal marshaller', 4
    unless check_gi_version (1, 33, 10);

  foreach my $package (qw/Gtk3::Dialog Gtk3::AboutDialog/) {
    my $d = $package->new;
    my $b = $d->add_button ('First Button', 'ok');
    $d->signal_connect (response => sub {
      is ($_[1], 'ok', "$package response");
      Gtk3::EVENT_STOP;
    });
    Glib::Idle->add( sub {
      $b->clicked;
      Glib::SOURCE_REMOVE;
    });
    is ($d->run, 'ok', "$package run");
    $d->hide;
  }
}

{
  my $d = Gtk3::Dialog->new;
  $d->set_alternative_button_order (2, 3);
  $d->set_alternative_button_order (qw(ok cancel accept), 3);
  $d->set_alternative_button_order;

  my $screen = Gtk3::Gdk::Screen::get_default;
  ok (defined Gtk3::alternative_dialog_button_order ($screen));
  ok (defined Gtk3::alternative_dialog_button_order (undef));
  ok (defined Gtk3::alternative_dialog_button_order);
}
