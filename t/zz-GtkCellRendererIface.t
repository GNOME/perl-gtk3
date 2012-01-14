#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;
use Glib ':constants';
use Cairo::GObject;

plan tests => 15;

{
  package StandAlone;
  use Glib::Object::Subclass
    Gtk3::CellRenderer::
    ;
  use Test::More;
  sub GET_PREFERRED_WIDTH {
    my ($cell, $widget) = @_;
    return (23, 42);
  }
  sub GET_ALIGNED_AREA {
    my ($cell, $widget, $flags, $cell_area) = @_;
    return $cell_area;
  }
  sub START_EDITING {
    my ($cell, $event, $widget, $path, $bg_area, $cell_area, $flags) = @_;
    return Gtk3::Entry->new;
  }
}

{
  my ($cell, $view) = prepare_cell ('StandAlone');

  my ($min, $nat) = $cell->get_preferred_width ($view);
  is ($min, 23);
  is ($nat, 42);

  my $rect = { x => 5, y => 5, width => 10, height => 10 };
  my $aligned_rect = $cell->get_aligned_area ($view, 'selected', $rect);
  is_deeply ($rect, $aligned_rect);

  $cell->set (mode => 'editable');
  my $event = Gtk3::Gdk::Event->new ("button-press");
  my $editable = $cell->start_editing ($event, $view, "0", $rect, $rect, qw(selected));
  isa_ok ($editable, "Gtk3::Entry");
  TODO: {
    local $TODO = 'ref-counting not quite right yet';
    my $destroyed = FALSE;
    $editable->signal_connect (destroy => sub { $destroyed = TRUE });
    undef $editable;
    ok ($destroyed, 'editable was destroyed');
  }
}

{
  package InheritorC;
  use Glib::Object::Subclass
    Gtk3::CellRendererText::
    ;
  sub GET_PREFERRED_WIDTH {
    return shift->SUPER::GET_PREFERRED_WIDTH (@_);
  }
  sub GET_ALIGNED_AREA {
    return shift->SUPER::GET_ALIGNED_AREA (@_);
  }
  sub START_EDITING {
    return shift->SUPER::START_EDITING (@_);
  }
}

{
  my ($cell, $view) = prepare_cell ('InheritorC');

  my ($min, $nat) = $cell->get_preferred_width ($view);
  ok (defined $min);
  ok (defined $nat);

  my $rect = { x => 5, y => 5, width => 10, height => 10 };
  my $aligned_rect = $cell->get_aligned_area ($view, 'selected', $rect);
  ok (exists $aligned_rect->{x});

  $cell->set (editable => TRUE);
  my $event = Gtk3::Gdk::Event->new ("button-press");
  my $editable = $cell->start_editing ($event, $view, "0", $rect, $rect, qw(selected));
  isa_ok ($editable, "Gtk3::Entry");
  TODO: {
    local $TODO = 'ref-counting not quite right yet';
    my $destroyed = FALSE;
    $editable->signal_connect (destroy => sub { $destroyed = TRUE });
    undef $editable;
    ok ($destroyed, 'editable was destroyed');
  }
}

{
  package InheritorPerl;
  use Glib::Object::Subclass
    StandAlone::
    ;
  sub GET_PREFERRED_WIDTH {
    return shift->SUPER::GET_PREFERRED_WIDTH (@_);
  }
  sub GET_ALIGNED_AREA {
    return shift->SUPER::GET_ALIGNED_AREA (@_);
  }
  sub START_EDITING {
    return shift->SUPER::START_EDITING (@_);
  }
}

{
  my ($cell, $view) = prepare_cell ('InheritorPerl');

  my ($min, $nat) = $cell->get_preferred_width ($view);
  ok (defined $min);
  ok (defined $nat);

  my $rect = { x => 5, y => 5, width => 10, height => 10 };
  my $aligned_rect = $cell->get_aligned_area ($view, 'selected', $rect);
  ok (exists $aligned_rect->{x});

  $cell->set (mode => 'editable');
  my $event = Gtk3::Gdk::Event->new ("button-press");
  my $editable = $cell->start_editing ($event, $view, "0", $rect, $rect, qw(selected));
  isa_ok ($editable, "Gtk3::Entry");
  TODO: {
    local $TODO = 'ref-counting not quite right yet';
    my $destroyed = FALSE;
    $editable->signal_connect (destroy => sub { $destroyed = TRUE });
    undef $editable;
    ok ($destroyed, 'editable was destroyed');
  }
}

sub prepare_cell {
  my ($package) = @_;

  my $model = Gtk3::ListStore->new ('Glib::String');
  foreach (qw/foo fluffy flurble frob frobnitz ftang fire truck/) {
    my $iter = $model->append;
    $model->set ($iter, 0, $_);
  }
  my $view = Gtk3::TreeView->new ($model);

  my $cell = $package->new;
  my $column = Gtk3::TreeViewColumn->new_with_attributes (
                 'stand-alone', $cell);
  $view->append_column ($column);

  return ($cell, $view);
}
