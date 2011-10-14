package Gtk3;

use strict;
use warnings;
use Carp qw/croak/;
use Glib::Object::Introspection;
use Exporter;

our @ISA = qw(Exporter);

my $_GTK_BASENAME = 'Gtk';
my $_GTK_VERSION = '3.0';
my $_GTK_PACKAGE = 'Gtk3';
my @_GTK_FLATTEN_ARRAY_REF_RETURN_FOR = qw/
  Gtk3::CellLayout::get_cells
  Gtk3::TreePath::get_indices
  Gtk3::Window::list_toplevels
/;
my @_GTK_HANDLE_SENTINEL_BOOLEAN_FOR = qw/
  Gtk3::TreeModel::get_iter
  Gtk3::TreeModel::get_iter_first
  Gtk3::TreeSelection::get_selected
/;

my $_GDK_BASENAME = 'Gdk';
my $_GDK_VERSION = '3.0';
my $_GDK_PACKAGE = 'Gtk3::Gdk';

my $_PANGO_BASENAME = 'Pango';
my $_PANGO_VERSION = '1.0';
my $_PANGO_PACKAGE = 'Pango';

sub import {
  my $class = shift;

  Glib::Object::Introspection->setup (
    basename => $_GTK_BASENAME,
    version => $_GTK_VERSION,
    package => $_GTK_PACKAGE,
    flatten_array_ref_return_for => \@_GTK_FLATTEN_ARRAY_REF_RETURN_FOR,
    handle_sentinel_boolean_for => \@_GTK_HANDLE_SENTINEL_BOOLEAN_FOR);

  Glib::Object::Introspection->setup (
    basename => $_GDK_BASENAME,
    version => $_GDK_VERSION,
    package => $_GDK_PACKAGE);

  Glib::Object::Introspection->setup (
    basename => $_PANGO_BASENAME,
    version => $_PANGO_VERSION,
    package => $_PANGO_PACKAGE);

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

sub Gtk3::CHECK_VERSION {
  return not defined Gtk3::check_version(@_ == 4 ? @_[1..3] : @_);
}

sub Gtk3::check_version {
  Glib::Object::Introspection->invoke ($_GTK_BASENAME, undef, 'check_version',
                                       @_ == 4 ? @_[1..3] : @_);
}

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

sub Gtk3::Button::new {
  my ($class, $label) = @_;
  if (defined $label) {
    return $class->new_with_mnemonic ($label);
  } else {
    return Glib::Object::Introspection->invoke (
      $_GTK_BASENAME, 'Button', 'new', @_);
  }
}

sub Gtk3::ListStore::new {
  return _common_tree_model_new ('ListStore', @_);
}

# Reroute 'get' to Gtk3::TreeModel instead of Glib::Object.
sub Gtk3::ListStore::get {
  return Gtk3::TreeModel::get (@_);
}

sub Gtk3::ListStore::set {
  return _common_tree_model_set ('ListStore', @_);
}

sub Gtk3::MessageDialog::new {
  my ($class, $parent, $flags, $type, $buttons, $format, @args) = @_;
  my $dialog = Glib::Object::new ($class, message_type => $type,
                                          buttons => $buttons);
  if (defined $format) {
    # sprintf can handle empty @args
    my $msg = sprintf $format, @args;
    $dialog->set (text => $msg);
  }
  if (defined $parent) {
    $dialog->set_transient_for ($parent);
  }
  if ($flags & 'modal') {
    $dialog->set_modal (Glib::TRUE);
  }
  if ($flags & 'destroy-with-parent') {
    $dialog->set_destroy_with_parent (Glib::TRUE);
  }
  return $dialog;
}

sub Gtk3::TreeModel::get {
  my ($model, $iter, @columns) = @_;
  my @values = map { $model->get_value ($iter, $_) } @columns;
  return @values[0..$#values];
}

sub Gtk3::TreePath::new {
  my ($class, @args) = @_;
  my $method = (@args == 1) ? 'new_from_string' : 'new';
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'TreePath', $method, @_);
}

sub Gtk3::TreeStore::new {
  return _common_tree_model_new ('TreeStore', @_);
}

# Reroute 'get' to Gtk3::TreeModel instead of Glib::Object.
sub Gtk3::TreeStore::get {
  return Gtk3::TreeModel::get (@_);
}

sub Gtk3::TreeStore::set {
  return _common_tree_model_set ('TreeStore', @_);
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

sub Gtk3::Window::new {
  my ($class, $type) = @_;
  $type = 'toplevel' unless defined $type;
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, 'Window', 'new', $class, $type);
}

# - Helpers ----------------------------------------------------------------- #

sub _common_tree_model_new {
  my ($package, $class, @types) = @_;
  local $@;
  my $real_types = (@types == 1 && eval { @{$types[0]} })
                 ? $types[0]
                 : \@types;
  return Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, $package, 'new',
    $class, $real_types);
}

sub _common_tree_model_set {
  my ($package, $model, $iter, @columns_and_values) = @_;
  my (@columns, @values);
  local $@;
  if (@columns_and_values == 2 && eval { @{$columns_and_values[0]} }) {
    @columns = @{$columns_and_values[0]};
    @values = @{$columns_and_values[1]};
  } elsif (@columns_and_values % 2 == 0) {
    my %cols_to_vals = @columns_and_values;
    @columns = keys %cols_to_vals;
    @values = values %cols_to_vals;
  } else {
    croak ('Usage: Gtk3::${package}::set ($store, \@columns, \@values)',
           ' -or-: Gtk3::${package}::set ($store, $column1 => $value1, ...)');
  }
  my @wrapped_values = ();
  foreach my $i (0..$#columns) {
    my $column_type = $model->get_column_type ($columns[$i]);
    push @wrapped_values,
         Glib::Object::Introspection::GValueWrapper->new (
           $column_type, $values[$i]);
  }
  Glib::Object::Introspection->invoke (
    $_GTK_BASENAME, $package, 'set',
    $model, $iter, \@columns, \@wrapped_values);
}

1;

__END__

# - Docs -------------------------------------------------------------------- #

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
