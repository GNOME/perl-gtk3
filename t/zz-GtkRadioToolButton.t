#!/usr/bin/perl

# Based on Gtk2/t/GtkRadioToolButton.t

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;

plan tests => 12;

my $item = Gtk3::RadioToolButton -> new();
isa_ok($item, "Gtk3::RadioToolButton");

my $item_two = Gtk3::RadioToolButton -> new(undef);
isa_ok($item_two, "Gtk3::RadioToolButton");

my $item_three = Gtk3::RadioToolButton -> new([$item, $item_two]);
isa_ok($item_three, "Gtk3::RadioToolButton");

$item_two = Gtk3::RadioToolButton -> new_from_stock(undef, "gtk-quit");
isa_ok($item_two, "Gtk3::RadioToolButton");

$item_three = Gtk3::RadioToolButton -> new_from_stock([$item, $item_two], "gtk-quit");
isa_ok($item_three, "Gtk3::RadioToolButton");

$item = Gtk3::RadioToolButton -> new_from_widget($item_two);
isa_ok($item, "Gtk3::RadioToolButton");

$item = Gtk3::RadioToolButton -> new_with_stock_from_widget($item_two, "gtk-quit");
isa_ok($item, "Gtk3::RadioToolButton");

$item = Gtk3::RadioToolButton -> new();
$item -> set_group([$item_two, $item_three]);
is_deeply($item -> get_group(), [$item_two, $item_three]);

{
  # get_group() no memory leaks in arrayref return and array items
  my $x = Gtk3::RadioToolButton->new;
  my $y = Gtk3::RadioToolButton->new;
  $y->set_group ($x);
  my $aref = $x->get_group;
  is_deeply ($aref, [$x,$y]);
  require Scalar::Util;
  Scalar::Util::weaken ($aref);
  is ($aref, undef, 'get_group() array destroyed by weakening');
  Scalar::Util::weaken ($x);
  is ($x, undef, 'get_group() item x destroyed by weakening');
  Scalar::Util::weaken ($y);
  is ($y, undef, 'get_group() item y destroyed by weakening');
}
