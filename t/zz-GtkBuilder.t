#!/usr/bin/perl

# Copied from Gtk2/t/GtkBuilder.t

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;

plan tests => 45;

my $builder;
my $ui = <<EOD;
<interface>
  <object class="GtkAdjustment" id="adjustment1">
    <property name="lower">0</property>
    <property name="upper">5</property>
    <property name="step-increment">1</property>
    <property name="value">5</property>
  </object>
  <object class="GtkSpinButton" id="spinbutton1">
    <property name="visible">True</property>
    <property name="adjustment">adjustment1</property>
    <signal name="value-changed" handler="value_changed" object="adjustment1" after="yes"/>
    <signal name="wrapped" handler="wrapped"/>
  </object>
</interface>
EOD

# --------------------------------------------------------------------------- #

my $ui_file = 'tmp.ui';

open my $fh, '>', $ui_file or plan skip_all => 'unable to create ui file';
print $fh $ui;
close $fh;

$builder = Gtk3::Builder->new;
isa_ok ($builder, 'Gtk3::Builder');

eval {
  $builder->add_from_file ('bla.ui');
};
like ($@, qr/bla\.ui/);

eval {
  ok ($builder->add_from_file ($ui_file) > 0);
};
is ($@, '');
isa_ok ($builder->get_object ('adjustment1'), 'Gtk3::Adjustment');

$builder->set_translation_domain (undef);
is ($builder->get_translation_domain, undef);
$builder->set_translation_domain ('de');
is ($builder->get_translation_domain, 'de');

{
  my $builder = Gtk3::Builder->new;
  eval {
    ok ($builder->add_objects_from_file ($ui_file, qw/adjustment1 spinbutton1/));
  };
  is ($@, '');
  ok (defined $builder->get_object ('adjustment1') &&
      defined $builder->get_object ('spinbutton1'));

  eval {
    $builder->add_objects_from_file ('bla.ui', qw/adjustment1 spinbutton1/);
  };
  like ($@, qr/bla\.ui/);

  $builder = Gtk3::Builder->new;
  eval {
    ok ($builder->add_objects_from_string ($ui, qw/adjustment1 spinbutton1/));
  };
  is ($@, '');
  ok (defined $builder->get_object ('adjustment1') &&
      defined $builder->get_object ('spinbutton1'));

  eval {
    $builder->add_objects_from_string ('<bla>', qw/adjustment1 spinbutton1/);
  };
  like ($@, qr/bla/);
}

unlink $ui_file;

# --------------------------------------------------------------------------- #

$builder = Gtk3::Builder->new;

eval {
  $builder->add_from_string ('<bla>');
};
like ($@, qr/bla/);

eval {
  ok ($builder->add_from_string ($ui) > 0);
};
is ($@, '');
my @objects = sort { ref $a cmp ref $b } $builder->get_objects;
isa_ok ($objects[0], 'Gtk3::Adjustment');
isa_ok ($objects[1], 'Gtk3::SpinButton');

$builder->connect_signals_full(sub {
  my ($builder,
      $object,
      $signal_name,
      $handler_name,
      $connect_object,
      $flags,
      $data) = @_;

  if ($signal_name ne 'value-changed') {
    return;
  }

  isa_ok ($builder, 'Gtk3::Builder');
  isa_ok ($object, 'Gtk3::SpinButton');
  is ($signal_name, 'value-changed');
  is ($handler_name, 'value_changed');
  isa_ok ($connect_object, 'Gtk3::Adjustment');
  ok ($flags == [ qw/after swapped/ ]);
  is ($data, 'data');
}, 'data');

# --------------------------------------------------------------------------- #

package BuilderTestCaller;

use Test::More; # for is(), isa_ok(), etc.
use Glib qw/:constants/;

sub value_changed {
  my ($spin, $data) = @_;

  isa_ok ($spin, 'Gtk3::SpinButton');
  isa_ok ($data, 'Gtk3::Adjustment');
}

sub wrapped {
  my ($spin, $data) = @_;

  isa_ok ($spin, 'Gtk3::SpinButton');
  is ($data, '!alb');
}

$builder = Gtk3::Builder->new;
$builder->add_from_string ($ui);
$builder->connect_signals ('!alb');

my $spin = $builder->get_object ('spinbutton1');
$spin->set_wrap (TRUE);
$spin->spin ('step-forward', 1);

# --------------------------------------------------------------------------- #

package BuilderTest;

use Test::More; # for is(), isa_ok(), etc.
use Glib qw/:constants/;

sub value_changed {
  my ($spin, $data) = @_;

  isa_ok ($spin, 'Gtk3::SpinButton');
  isa_ok ($data, 'Gtk3::Adjustment');
}

sub wrapped {
  my ($spin, $data) = @_;

  isa_ok ($spin, 'Gtk3::SpinButton');
  is ($data, 'bla!');
}

$builder = Gtk3::Builder->new;
$builder->add_from_string ($ui);
$builder->connect_signals ('bla!', 'BuilderTest');

$spin = $builder->get_object ('spinbutton1');
$spin->set_wrap (TRUE);
$spin->spin ('step-forward', 1);

# --------------------------------------------------------------------------- #

package BuilderTestOO;

use Test::More; # for is(), isa_ok(), etc.
use Glib qw/:constants/;

sub value_changed {
  my ($self, $spin, $data) = @_;

  is ($self->{answer}, 42);
  isa_ok ($spin, 'Gtk3::SpinButton');
  isa_ok ($data, 'Gtk3::Adjustment');
}

sub wrapped {
  my ($self, $spin, $data) = @_;

  is ($self->{answer}, 42);
  isa_ok ($spin, 'Gtk3::SpinButton');
  is ($data, 'bla!');
}

my $self = bless { answer => 42 }, 'BuilderTestOO';

$builder = Gtk3::Builder->new;
$builder->add_from_string ($ui);
$builder->connect_signals ('bla!', $self);

$spin = $builder->get_object ('spinbutton1');
$spin->set_wrap (TRUE);
$spin->spin ('step-forward', 1);

# --------------------------------------------------------------------------- #

$builder = Gtk3::Builder->new;
$builder->add_from_string ($ui);
$builder->connect_signals ('!alb',
  value_changed => \&BuilderTest::value_changed,
  wrapped => \&BuilderTestCaller::wrapped
);

$spin = $builder->get_object ('spinbutton1');
$spin->set_wrap (TRUE);
$spin->spin ('step-forward', 1);

__END__

Copyright (C) 2007 by the gtk2-perl team
