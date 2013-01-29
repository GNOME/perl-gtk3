#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;
use Glib ':constants';

plan tests => 35;

my $cell = Gtk3::CellRendererText->new ();

my $layout = CustomCellLayout->new ();
$layout->pack_start ($cell, TRUE);
$layout->pack_end ($cell, FALSE);
$layout->clear ();
$layout->add_attribute ($cell, text => 42);
$layout->clear_attributes ($cell);
$layout->set_attributes ($cell, text => 42);
$layout->reorder ($cell, 42);

my @cells = $layout->get_cells ();
is (scalar @cells, 2);
isa_ok ($cells[0], 'Gtk3::CellRendererText');
isa_ok ($cells[1], 'Gtk3::CellRendererToggle');

SKIP: {
  skip 'tree model ctors not properly supported', 9
    unless check_gi_version(1, 29, 17);
  my $callback = sub {
    my ($cb_layout, $cb_cell, $model, $iter, $data) = @_;
    is ($cb_layout, $layout);
    is ($cb_cell, $cell);
    isa_ok ($model, 'Gtk3::ListStore');
    isa_ok ($iter, 'Gtk3::TreeIter');
    is ($data, 'bla!');
  };
  $layout->set_cell_data_func ($cell, $callback, 'bla!');
  $layout->set_cell_data_func ($cell, undef);
}

package CustomCellLayout;

use strict;
use warnings;
use Glib ':constants';

use Test::More;

use Glib::Object::Subclass
    Gtk3::Widget::,
    interfaces => [ Gtk3::CellLayout:: ],
    ;

sub PACK_START {
  my ($self, $cell, $expand) = @_;
  isa_ok ($self, __PACKAGE__);
  isa_ok ($cell, 'Gtk3::CellRenderer');
  is ($expand, TRUE);
}

sub PACK_END {
  my ($self, $cell, $expand) = @_;
  isa_ok ($self, __PACKAGE__);
  isa_ok ($cell, 'Gtk3::CellRenderer');
  is ($expand, FALSE);
}

sub CLEAR {
  my ($self) = @_;
  isa_ok ($self, __PACKAGE__);
}

sub ADD_ATTRIBUTE {
  my ($self, $cell, $attribute, $column) = @_;
  isa_ok ($self, __PACKAGE__);
  isa_ok ($cell, 'Gtk3::CellRenderer');
  is ($attribute, 'text');
  is ($column, 42);
}

sub SET_CELL_DATA_FUNC {
  my ($self, $cell, $func, $data) = @_;
  isa_ok ($self, __PACKAGE__);
  isa_ok ($cell, 'Gtk3::CellRenderer');
  if (defined $func) {
    my $model = Gtk3::ListStore->new (qw/Glib::String/);
    $func->($self, $cell, $model, $model->append (), $data);
  }
}

sub CLEAR_ATTRIBUTES {
  my ($self, $cell) = @_;
  isa_ok ($self, __PACKAGE__);
  isa_ok ($cell, 'Gtk3::CellRenderer');
}

sub REORDER {
  my ($self, $cell, $position) = @_;
  isa_ok ($self, __PACKAGE__);
  isa_ok ($cell, 'Gtk3::CellRenderer');
  is ($position, 42);
}

sub grow_the_stack { 0 .. 500 };

sub GET_CELLS {
  my ($self) = @_;
  isa_ok ($self, __PACKAGE__);
  $self->{cell_one} = Gtk3::CellRendererText->new;
  $self->{cell_two} = Gtk3::CellRendererToggle->new;
  my @list = grow_the_stack();
  return [$self->{cell_one}, $self->{cell_two}];
}
