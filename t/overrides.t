#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' };

use strict;
use warnings;

plan tests => 29;

# Gtk3::CHECK_VERSION and check_version
{
  my ($x, $y, $z) = (Gtk3::MAJOR_VERSION, Gtk3::MINOR_VERSION, Gtk3::MICRO_VERSION);
  ok (Gtk3::CHECK_VERSION ($x, $y, $z));
  ok (Gtk3->CHECK_VERSION ($x, $y, $z));
  ok (not defined Gtk3::check_version ($x, $y, $z));
  ok (not defined Gtk3->check_version ($x, $y, $z));

  $z++;
  ok (!Gtk3::CHECK_VERSION ($x, $y, $z));
  ok (!Gtk3->CHECK_VERSION ($x, $y, $z));
  ok (defined Gtk3::check_version ($x, $y, $z));
  ok (defined Gtk3->check_version ($x, $y, $z));
}

# Gtk3::CellLayout::get_cells
{
  my $cell = Gtk3::TreeViewColumn->new;
  is_deeply([$cell->get_cells], []);
  my $one = Gtk3::CellRendererText->new;
  my $two = Gtk3::CellRendererText->new;
  $cell->pack_start($one, 0);
  $cell->pack_start($two, 1);
  is_deeply([$cell->get_cells], [$one, $two]);
}

# Gtk3::ListStore::new, set and get
{
  my $model = Gtk3::ListStore->new ([qw/Glib::String Glib::Int/]);
  my $iter = $model->append;
  $model->set ($iter, [0, 1], ['Foo', 23]);
  is_deeply ([$model->get ($iter, 0,1)], ['Foo', 23]);
  is (scalar $model->get ($iter, 0,1), 23);

  $iter = $model->append;
  $model->set ($iter, 0 => 'Bar', 1 => 42);
  is_deeply ([$model->get ($iter, 0,1)], ['Bar', 42]);
  is (scalar $model->get ($iter, 0,1), 42);

  local $@;
  eval { $model->set ($iter, 0) };
  like ($@, qr/Usage/);
}

# Gtk3::TreeModel::get_iter and get_iter_first
{
  my $model = Gtk3::ListStore->new ('Glib::String');
  my $path = Gtk3::TreePath->new_from_string ('0');
  is ($model->get_iter ($path), undef);
  is ($model->get_iter_first, undef);
  my $iter = $model->append;
  isa_ok ($model->get_iter ($path), 'Gtk3::TreeIter');
  isa_ok ($model->get_iter_first, 'Gtk3::TreeIter');
}

# Gtk3::TreePath::get_indices
{
  # my $path = Gtk3::TreePath->new_from_indices ([1, 2, 3]); # FIXME
  my $path = Gtk3::TreePath->new_from_string ('1:2:3');
  is_deeply ([$path->get_indices], [1, 2, 3]);
}

# Gtk3::TreeSelection::get_selected
{
  my $model = Gtk3::ListStore->new ('Glib::String');
  my $view = Gtk3::TreeView->new ($model);
  my $selection = $view->get_selection;
  my $iter = $model->append;
  $selection->select_iter ($iter);
  my ($sel_model, $sel_iter) = $selection->get_selected;
  is ($sel_model, $model);
  isa_ok ($sel_iter, 'Gtk3::TreeIter');
}

# Gtk3::TreeStore::new, set and get
{
  my $model = Gtk3::TreeStore->new ([qw/Glib::String Glib::Int/]);
  my $iter = $model->append (undef);
  $model->set ($iter, [0, 1], ['Foo', 23]);
  is_deeply ([$model->get ($iter, 0,1)], ['Foo', 23]);
  is (scalar $model->get ($iter, 0,1), 23);

  $iter = $model->append (undef);
  $model->set ($iter, 0 => 'Bar', 1 => 42);
  is_deeply ([$model->get ($iter, 0,1)], ['Bar', 42]);
  is (scalar $model->get ($iter, 0,1), 42);

  local $@;
  eval { $model->set ($iter, 0) };
  like ($@, qr/Usage/);
}

# Gtk3::Window::new and list_toplevels
{
  my $window1 = Gtk3::Window->new ('toplevel');
  my $window2 = Gtk3::Window->new;
  is_deeply ([Gtk3::Window::list_toplevels ()], [$window1, $window2]);
  is (scalar Gtk3::Window::list_toplevels (), $window2);
}
