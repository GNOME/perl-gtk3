#!/usr/bin/perl
#
# Originally copied from Gtk2/t/GtkImage.t
#

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;

plan tests => 32;

# borrowed from xsane-icons.c
my @pixbuf_data =
(
        "    20    20        4            1",
        "  none",
        ". c #000000",
        "+ c #208020",
        "a c #ffffff",
        "                    ",
        " .................  ",
        " .+++++++++++++++.  ",
        " .+      .      +.  ",
        " .+     ...     +.  ",
        " .+    . . .    +.  ",
        " .+      .      +.  ",
        " .+      .      +.  ",
        " .+  .   .   .  +.  ",
        " .+ .    .    . +.  ",
        " .+.............+.  ",
        " .+ .    .    . +.  ",
        " .+  .   .   .  +.  ",
        " .+      .      +.  ",
        " .+    . . .    +.  ",
        " .+     ...     +.  ",
        " .+      .      +.  ",
        " .+++++++++++++++.  ",
        " .................  ",
        "                    ",
);

my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_xpm_data (@pixbuf_data);

# Plain old new ################################################################

ok (my $img = Gtk3::Image->new, 'Gtk3::Image->new');

is_deeply ([$img->get_icon_set], [undef, 'invalid'], 'get_icon_set empty');
is ($img->get_pixbuf, undef, 'get_pixbuf empty');
is_deeply ([$img->get_stock ()], [undef, 'invalid'], 'get_stock empty');
is ($img->get_animation, undef, 'get_animation empty');
is ($img->get_storage_type, 'empty', 'get_storage_type empty');

# new from stock ###############################################################

ok ($img = Gtk3::Image->new_from_stock ('gtk-cancel', 'menu'),
  'Gtk3::Image->new_from_stock');
is ($img->get_storage_type, 'stock', 'new_from_stock get_storage_type');
is_deeply ([$img->get_stock ()], ['gtk-cancel', 'menu'],
           'new_from_stock get_stock');

# new from icon set ############################################################

my $iconset = Gtk3::IconSet->new_from_pixbuf ($pixbuf);
ok ($img = Gtk3::Image->new_from_icon_set ($iconset, 'small-toolbar'),
  'Gtk3::Image->new_from_icon_set');
my @ret = $img->get_icon_set;
is (scalar (@ret), 2, 'new_from_icon_set get_icon_set num rets');
isa_ok ($ret[0], 'Gtk3::IconSet', 'new_from_icon_set get_icon_set icon_set');
is ($ret[1], 'small-toolbar', 'new_from_icon_set get_icon_set size');

# new from pixbuf ##############################################################

ok ($img = Gtk3::Image->new_from_pixbuf ($pixbuf),
  'Gtk3::Image->new_from_pixbuf');
isa_ok ($img->get_pixbuf, 'Gtk3::Gdk::Pixbuf', 'new_from_pixbuf get_pixbuf');

# set from stock ###############################################################

$img->set_from_stock ('gtk-quit', 'dialog');
is ($img->get_storage_type, 'stock', 'set_from_stock get_storage_type');
ok (eq_array ([$img->get_stock ()], ['gtk-quit', 'dialog']),
  'set_from_stock get_stock');

# set from icon set ############################################################

$img->set_from_icon_set ($iconset, 'small-toolbar');
@ret = $img->get_icon_set;
is (scalar (@ret), 2, 'set_from_icon_set get_icon_set num rets');
isa_ok ($ret[0], 'Gtk3::IconSet', 'set_from_icon_set get_icon_set icon_set');
is ($ret[1], 'small-toolbar', 'set_from_icon_set get_icon_set size');

# set from pixbuf ##############################################################

$img->set_from_pixbuf (undef);
$img->set_from_pixbuf ($pixbuf);
isa_ok ($img->get_pixbuf, 'Gtk3::Gdk::Pixbuf', 'set_from_pixbuf get_pixbuf');

# These require access to a file, so they may be skipped

my $testfile = './gtk-demo/gnome-foot.png';

SKIP:
{
  skip "unable to find test file, $testfile", 7
    unless (-R $testfile);

  my $animation = Gtk3::Gdk::PixbufAnimation->new_from_file ($testfile);

  # new from file ##############################################################

  ok ($img = Gtk3::Image->new_from_file (''),
    'Gtk3::Image->new_from_file undef');
  ok ($img = Gtk3::Image->new_from_file ($testfile),
    'Gtk3::Image->new_from_file');
  isa_ok ($img->get_pixbuf, 'Gtk3::Gdk::Pixbuf',
    'new_from_file get_pixbuf');

  # new from animation #########################################################

  ok ($img = Gtk3::Image->new_from_animation ($animation),
    'Gtk3::Image->new_from_animation');
  isa_ok ($img->get_animation, 'Gtk3::Gdk::PixbufAnimation',
    'new_from_animation get_animationf');

  # set from file ##############################################################

  $img->set_from_file (undef);
  $img->set_from_file ($testfile);
  isa_ok ($img->get_pixbuf, 'Gtk3::Gdk::Pixbuf',
    'set_from_file get_pixbuf');

  # set from animation #########################################################

  $img->set_from_animation ($animation);
  isa_ok ($img->get_animation, 'Gtk3::Gdk::PixbufAnimation',
    'set_from_animation get_animation');
}

$img = Gtk3::Image->new_from_icon_name ('gtk-ok', 'button');
isa_ok ($img, 'Gtk3::Image', 'new_from_icon_name isa Gtk3::Image');
is_deeply ([$img->get_icon_name], ['gtk-ok', 'button'], 'deep get_icon_name');

$img->set_from_icon_name ('gtk-cancel', 'menu');
is_deeply ([$img->get_icon_name], ['gtk-cancel', 'menu'],
  'get_icon_name from Gtk3::Image set_from_icon_name');

$img->set_pixel_size (23);
is ($img->get_pixel_size, 23, 'Gtk3::Image get_pixel_size');

$img->clear;

__END__

Copyright (C) 2003-2013 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.
