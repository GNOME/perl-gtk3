#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' };

use strict;
use warnings;
use Scalar::Util qw/weaken/;

plan tests => 2;

SKIP: {
  my $button = Gtk3::Button->new_with_label ('Label');
  weaken $button;
  is ($button, undef);
}

SKIP: {
  skip 'Window ref counting test', 1; # FIXME?
  my $window = Gtk3::Window->new ('toplevel');
  weaken $window;
  is ($window, undef);
}
