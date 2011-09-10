#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' };

use strict;
use warnings;

plan tests => 11;

# Gtk3::Window::list_toplevels
{
  my $window1 = Gtk3::Window->new ('toplevel');
  my $window2 = Gtk3::Window->new ('toplevel');
  is_deeply ([Gtk3::Window::list_toplevels ()], [$window1, $window2]);
  is (scalar Gtk3::Window::list_toplevels (), $window2);
}

# Gtk3::ListStore->new, set and get
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

# Gtk3::TreeModel->get_iter_first
{
  my $model = Gtk3::ListStore->new ('Glib::String');
  is ($model->get_iter_first, undef);
  my $iter = $model->append;
  isa_ok ($model->get_iter_first, 'Gtk3::TreeIter');
}

# Gtk3::TreeSelection->get_selected
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
