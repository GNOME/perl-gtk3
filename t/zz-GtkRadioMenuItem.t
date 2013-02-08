#!/usr/bin/perl

# Based on Gtk2/t/GtkRadioMenuItem.t

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;

plan tests => 11;

SKIP: {
  skip 'list-based API; it is broken currently', 9
    unless 0; # FIXME: <https://bugzilla.gnome.org/show_bug.cgi?id=679563>

  my $item_one = Gtk3::RadioMenuItem -> new();
  isa_ok($item_one, "Gtk3::RadioMenuItem");

  my $item_two = Gtk3::RadioMenuItem -> new($item_one -> get_group());
  isa_ok($item_two, "Gtk3::RadioMenuItem");

  my $item_three = Gtk3::RadioMenuItem -> new_with_label([], "Bla");
  isa_ok($item_three, "Gtk3::RadioMenuItem");

  my $item_four = Gtk3::RadioMenuItem -> new_with_mnemonic([$item_one, $item_two], "_Bla");
  isa_ok($item_four, "Gtk3::RadioMenuItem");

  $item_three -> set_group($item_one -> get_group());
  is_deeply($item_one -> get_group(),
            [$item_one, $item_two, $item_three, $item_four]);

  my $item_five = Gtk3::RadioMenuItem -> new_from_widget($item_one);
  isa_ok($item_five, "Gtk3::RadioMenuItem");

  my $item_six = Gtk3::RadioMenuItem -> new_with_label_from_widget($item_two, "Bla");
  isa_ok($item_six, "Gtk3::RadioMenuItem");

  my $item_seven = Gtk3::RadioMenuItem -> new_with_mnemonic_from_widget($item_three, "_Bla");
  isa_ok($item_seven, "Gtk3::RadioMenuItem");

  is_deeply($item_one -> get_group(),
            [$item_one, $item_two, $item_three, $item_four,
             $item_five, $item_six, $item_seven]);
}

SKIP: {
  skip 'item-based API; missing annotations', 2
    unless Gtk3::CHECK_VERSION (3, 6, 0);

  # FIXME: The item-based API is not bootstrap-able on its own yet, see
  # <https://bugzilla.gnome.org/show_bug.cgi?id=679563>.
  # my $item_one = Gtk3::RadioMenuItem -> new_from_widget(undef);

  my $item_one = Gtk3::RadioMenuItem -> new([]);
  my $item_two = Gtk3::RadioMenuItem -> new($item_one);
  my $item_three = Gtk3::RadioMenuItem -> new_with_label($item_one, "Bla");
  my $item_four = Gtk3::RadioMenuItem -> new_with_mnemonic($item_one, "_Bla");
  is_deeply($item_one -> get_group(), [$item_one, $item_two, $item_three, $item_four]);

  my $item_five = Gtk3::RadioMenuItem -> new_from_widget($item_one);
  my $item_six = Gtk3::RadioMenuItem -> new_with_label_from_widget($item_two, "Bla");
  my $item_seven = Gtk3::RadioMenuItem -> new_with_mnemonic_from_widget($item_three, "_Bla");
  is_deeply($item_seven -> get_group(),
            [$item_one, $item_two, $item_three, $item_four,
             $item_five, $item_six, $item_seven]);
}

__END__

Copyright (C) 2003-2012 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.
