#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' };

use strict;
use warnings;

plan tests => 3;

# Gtk3::Widget.size-allocate
{
  my $window = Gtk3::Window->new;
  $window->show;
  my $alloc = {x => 10, y => 10, width => 100, height => 100};
  my $data = [23, 42];
  $window->signal_connect (size_allocate => sub {
    my ($cb_window, $cb_alloc, $cb_data) = @_;
    is ($cb_window, $window);
    is_deeply ($cb_alloc, $alloc);
    is_deeply ($cb_data, $data);
  }, $data);
  $window->signal_emit (size_allocate => $alloc);
}
