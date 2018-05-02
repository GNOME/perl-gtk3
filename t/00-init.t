#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

BEGIN { require Gtk3; }
unless (eval { Gtk3->import; 1 }) {
  my $error = $@;
  if (eval { $error->isa ('Glib::Error') &&
             $error->domain eq 'g-irepository-error-quark'})
  {
    BAIL_OUT ("OS unsupported: $error");
  } else {
    BAIL_OUT ("Cannot load Gtk3: $error");
  }
}

plan tests => 16;

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

# Ensure that error messages are reported at the point in the program, not in
# Gtk3.pm.
{
  eval { my $b = Gtk3::LinkButton->new; };
  like ($@, qr/00-init\.t/);
}

my @run_version = Gtk3->get_version_info;
my @compile_version = Gtk3->GET_VERSION_INFO;

diag 'Testing Gtk3 ', $Gtk3::VERSION;
diag '   Running against gtk+ ', join '.', @run_version;
diag '  Compiled against gtk+ ', join '.', @compile_version;

is (@run_version, 3, 'version info is three items long' );
is (Gtk3->check_version(0,0,0), 'GTK+ version too new (major mismatch)',
    'check_version fail 1');
is (Gtk3->check_version(3,0,0), undef, 'check_version pass');
is (Gtk3->check_version(50,0,0), 'GTK+ version too old (major mismatch)',
    'check_version fail 2');
ok (defined (Gtk3::get_major_version()), 'major_version');
ok (defined (Gtk3::get_minor_version()), 'minor_version');
ok (defined (Gtk3::get_micro_version()), 'micro_version');

is (@compile_version, 3, 'version info is three items long');
ok (Gtk3->CHECK_VERSION(3,0,0), 'CHECK_VERSION pass');
ok (!Gtk3->CHECK_VERSION(50,0,0), 'CHECK_VERSION fail');
is (Gtk3->MAJOR_VERSION, $compile_version[0], 'MAJOR_VERSION');
is (Gtk3->MINOR_VERSION, $compile_version[1], 'MINOR_VERSION');
is (Gtk3->MICRO_VERSION, $compile_version[2], 'MICRO_VERSION');
