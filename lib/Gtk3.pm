package Gtk3;

use strict;
use warnings;
use Glib::Object::Introspection;
use Exporter;

our @ISA = qw(Exporter);

my $_GTK_BASENAME = 'Gtk';
my $_GTK_VERSION = '3.0';
my $_GTK_PACKAGE = 'Gtk3';

sub import {
  my $class = shift;

  Glib::Object::Introspection->setup (
    basename => $_GTK_BASENAME,
    version => $_GTK_VERSION,
    package => $_GTK_PACKAGE);

  my $init = 0;
  my @unknown_args = ($class);
  foreach (@_) {
    if (/^-?init$/) {
      $init = 1;
    } else {
      push @unknown_args, $_;
    }
  }

  if ($init) {
    Gtk3::init ();
  }

  # call into Exporter for the unrecognized arguments; handles exporting and
  # version checking
  Gtk3->export_to_level (1, @unknown_args);
}

# - Overrides --------------------------------------------------------------- #

sub Gtk3::init {
  my $rest = Glib::Object::Introspection->invoke (
               $_GTK_BASENAME, undef, 'init',
               [$0, @ARGV]);
  @ARGV = @{$rest}[1 .. $#$rest]; # remove $0
  return;
}

sub Gtk3::init_check {
  my ($success, $rest) = Glib::Object::Introspection->invoke (
                           $_GTK_BASENAME, undef, 'init_check',
                           [$0, @ARGV]);
  @ARGV = @{$rest}[1 .. $#$rest]; # remove $0
  return $success;
}

sub Gtk3::main {
  # Ignore any arguments passed in.
  Glib::Object::Introspection->invoke ($_GTK_BASENAME, undef, 'main');
}

sub Gtk3::main_quit {
  # Ignore any arguments passed in.
  Glib::Object::Introspection->invoke ($_GTK_BASENAME, undef, 'main_quit');
}

sub Gtk3::ListStore::new {
  my ($class, @types) = @_;
  my $real_types = (@types == 1 && eval { @{$types[0]} })
                 ? $types[0]
                 : \@types;
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'ListStore', 'new',
    $class, $real_types);
}

sub Gtk3::ListStore::set {
  my ($model, $iter, @columns_and_values) = @_;
  my (@columns, @values);
  if (@columns_and_values == 2 && eval { @{$columns_and_values[0]} }) {
    @columns = @{$columns_and_values[0]};
    @values = @{$columns_and_values[1]};
  } elsif (@columns_and_values % 2 == 0) {
    my %cols_to_vals = @columns_and_values;
    @columns = keys %cols_to_vals;
    @values = values %cols_to_vals;
  } else {
    # FIXME
  }
  my @wrapped_values = ();
  foreach my $i (0..$#columns) {
    my $column_type = $model->get_column_type ($columns[$i]);
    push @wrapped_values,
         Glib::Object::Introspection::GValueWrapper->new (
           $column_type, $values[$i]);
  }
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'ListStore', 'set',
    $model, $iter, \@columns, \@wrapped_values);
}

sub Gtk3::TreePath::new {
  my ($class, @args) = @_;
  my $method = (@args == 1) ? 'new_from_string' : 'new';
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'TreePath', $method, @_);
}

sub Gtk3::TreeView::new {
  my ($class, @args) = @_;
  my $method = (@args == 1) ? 'new_with_model' : 'new';
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'TreeView', $method, @_);
}

sub Gtk3::TreeViewColumn::new_with_attributes {
  my ($class, $title, $cell, %attr_to_column) = @_;
  my $object = $class->new;
  $object->set_title ($title);
  $object->pack_start ($cell, Glib::TRUE);
  foreach my $attr (keys %attr_to_column) {
    $object->add_attribute ($cell, $attr, $attr_to_column{$attr});
  }
  return $object;
}

1;

__END__

# - Docs --------------------------------------------------------------- #

=head1 NAME

Gtk3 - Perl interface to the 2.x series of the Gimp Toolkit library

=head1 SYNOPSIS

  XXX

=head1 ABSTRACT

XXX

=head1 DESCRIPTION

XXX

=head1 SEE ALSO

XXX

=head1 AUTHORS

=encoding utf8

XXX

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Torsten Schoenfeld <kaffeetisch@gmx.de>

This library is free software; you can redistribute it and/or modify it under
the terms of the Lesser General Public License (LGPL).  For more information,
see http://www.fsf.org/licenses/lgpl.txt

=cut
