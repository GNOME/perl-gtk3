#!perl

# Ensure that importing Gtk3 multiple times does not break vfunc overloading.

package MyButton;

use strict;
use warnings;

# First import.
use Gtk3;

use Glib::Object::Subclass
    Gtk3::Button::,
    signals => {},
    properties => [],
    ;

package main;

use strict;
use warnings;

# Second import.
use Gtk3;

use Test::More;
if (!eval { Glib::Object::Introspection->VERSION ('0.030') }) {
  plan skip_all => 'G:O:I 0.030 required';
}
if (!Gtk3::init_check ()) {
  plan skip_all => 'Gtk3::init_check failed';
}
plan tests => 1;

my $window = Gtk3::Window->new;
my $my_button = MyButton->new (label => "Test");
$window->add ($my_button); # trigger PARENT_SET
pass;
