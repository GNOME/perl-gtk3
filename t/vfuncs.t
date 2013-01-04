#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' };

use strict;
use warnings;

plan tests => 2;

# Make sure that we can safely inherit from classes which have a "destroy"
# vfunc.
{
  my $label_destroy_called = 0;
  my $label_destroy_chain_called = 0;

  package MyLabel;
  use Glib::Object::Subclass
    Gtk3::Label::
    ;
  # no DESTROY_VFUNC override

  package MyLabelDestroy;
  use Glib::Object::Subclass
    Gtk3::Label::
    ;
  sub DESTROY_VFUNC {
    $label_destroy_called++;
  }

  package MyLabelDestroyChain;
  use Glib::Object::Subclass
    Gtk3::Label::
    ;
  sub DESTROY_VFUNC {
    $label_destroy_chain_called++;
    $_[0]->SUPER::DESTROY_VFUNC ();
  }

  package main;
  {
    my $label = MyLabel->new;
    my $label_destroy = MyLabelDestroy->new;
    my $label_destroy_chan = MyLabelDestroyChain->new;
  }
  is ($label_destroy_called, 1);
  is ($label_destroy_chain_called, 1);
}
