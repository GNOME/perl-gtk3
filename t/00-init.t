#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 2;

BEGIN { use_ok('Gtk3') };

SKIP: {
  @ARGV = qw(--help --name gtk2perl --urgs tree);
  skip 'Gtk3::init_check failed, probably unable to open DISPLAY', 1
    unless Gtk3::init_check ();
  Gtk3::init ();
  is_deeply (\@ARGV, [qw(--help --urgs tree)]);
}

__END__

Copyright (C) 2011 by the gtk2-perl team (see the file AUTHORS for the full
list).  See LICENSE for more information.
