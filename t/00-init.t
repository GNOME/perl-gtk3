#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

BEGIN { require Gtk3; }
my $success = eval { Gtk3->import; 1 };
BAIL_OUT ("Cannot load Gtk3: $@")
  unless $success;

plan tests => 2;

SKIP: {
  @ARGV = qw(--help --name gtk2perl --urgs tree);
  skip 'Gtk3::init_check failed, probably unable to open DISPLAY', 2
    unless Gtk3::init_check ();
  Gtk3::init ();
  is_deeply (\@ARGV, [qw(--help --urgs tree)]);

  # Ensure that version parsing still works after the setlocale() done by
  # Gtk3::init().
  ok (defined eval 'use 5.8.0; 1');
}
