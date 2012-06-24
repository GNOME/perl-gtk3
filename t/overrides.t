#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' };

use strict;
use warnings;

plan tests => 80;

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

# Gtk3::Window::new and list_toplevels.  This is at the top to avoid testing
# against a polluted list of toplevels.
{
  my $window1 = Gtk3::Window->new ('toplevel');
  my $window2 = Gtk3::Window->new;
  is_deeply ([Gtk3::Window::list_toplevels ()], [$window1, $window2]);
  is (scalar Gtk3::Window::list_toplevels (), $window2);
}

# Gtk3::show_about_dialog
{
  my %props = (program_name => 'Foo',
               version => '42',
               authors => [qw/me myself i/],
               license_type => 'lgpl-2-1');
  Gtk3::show_about_dialog (undef, %props);
  Gtk3->show_about_dialog (undef, %props);
  Gtk3::show_about_dialog (Gtk3::Window->new, %props);
  Gtk3->show_about_dialog (Gtk3::Window->new, %props);
  ok (1);
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
SKIP: {
  skip 'tree model ctors not properly supported', 5
    unless check_gi_version(1, 29, 17);

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

# Gtk3::Menu::popup and popup_for_device
SKIP: {
  skip 'incorrect annotations for menu position callbacks', 2
    unless Gtk3::CHECK_VERSION (3, 2, 0);

  {
    my $menu = Gtk3::Menu->new;
    my $position_callback = sub {
      my ($menu, $data) = @_;
      isa_ok ($menu, "Gtk3::Menu");
      return @$data;
    };
    $menu->popup (undef, undef, $position_callback, [50, 50], 1, 0);
    $menu->popup_for_device (undef, undef, undef, $position_callback, [50, 50, Glib::TRUE], 1, 0);
  }

  # Test this separately to ensure that specifying no callback does not lead to
  # an invalid invocation of the destroy notify func.
  {
    my $menu = Gtk3::Menu->new;
    $menu->popup (undef, undef, undef, undef, 1, 0);
  }
}

# Gtk2::MenuItem::new, Gtk2::CheckMenuItem::new, Gtk2::ImageMenuItem::new
{
  foreach my $class (qw/Gtk3::MenuItem Gtk3::CheckMenuItem Gtk3::ImageMenuItem/) {
    my $item;

    $item = $class->new;
    isa_ok ($item, $class);
    ok (!$item->get_label); # might be '' or undef

    $item = $class->new ('_Test');
    isa_ok ($item, $class);
    is ($item->get_label, '_Test');

    $item = $class->new_with_mnemonic ('_Test');
    isa_ok ($item, $class);
    is ($item->get_label, '_Test');
  }
}

# Gtk3::Stock
{
  ok (grep { $_ eq 'gtk-ok' } Gtk3::Stock::list_ids ());
  my $item = Gtk3::Stock::lookup ('gtk-ok');
  is ($item->{stock_id}, 'gtk-ok');
  # Gtk3::Stock::add and add_static don't work yet
  Gtk3::Stock::set_translate_func ('perl-domain', sub {}, 42);
}

# Gtk3::TreeStore::new, set and get
SKIP: {
  skip 'tree model ctors not properly supported', 5
    unless check_gi_version(1, 29, 17);

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

# Gtk3::TreePath::new, new_from_string, new_from_indices, get_indices
{
  my $path = Gtk3::TreePath->new;
  isa_ok ($path, 'Gtk3::TreePath');
  $path = Gtk3::TreePath->new ('1:2:3');
  is_deeply ([$path->get_indices], [1, 2, 3]);
  $path = Gtk3::TreePath->new_from_string ('1:2:3');
  is_deeply ([$path->get_indices], [1, 2, 3]);
  $path = Gtk3::TreePath->new_from_indices (1, 2, 3);
  is_deeply ([$path->get_indices], [1, 2, 3]);
}

# Gtk3::TreeModel::get_iter, get_iter_first, get_iter_from_string
SKIP: {
  skip 'tree model ctors not properly supported', 6
    unless check_gi_version(1, 29, 17);

  my $model = Gtk3::ListStore->new ('Glib::String');
  my $path = Gtk3::TreePath->new_from_string ('0');
  is ($model->get_iter ($path), undef);
  is ($model->get_iter_first, undef);
  is ($model->get_iter_from_string ('0'), undef);
  my $iter = $model->append;
  isa_ok ($model->get_iter ($path), 'Gtk3::TreeIter');
  isa_ok ($model->get_iter_first, 'Gtk3::TreeIter');
  isa_ok ($model->get_iter_from_string ('0'), 'Gtk3::TreeIter');
}

# Gtk3::TreeModel::iter_children, iter_nth_child, iter_parent
SKIP: {
  skip 'tree model ctors not properly supported', 6
    unless check_gi_version(1, 29, 17);

  my $model = Gtk3::TreeStore->new ([qw/Glib::String/]);
  my $parent_iter = $model->append (undef);
  is ($model->iter_children ($parent_iter), undef);
  is ($model->iter_nth_child ($parent_iter, 0), undef);
  is ($model->iter_parent ($parent_iter), undef);
  my $child_iter = $model->append ($parent_iter);
  isa_ok ($model->iter_children ($parent_iter), 'Gtk3::TreeIter');
  isa_ok ($model->iter_nth_child ($parent_iter, 0), 'Gtk3::TreeIter');
  isa_ok ($model->iter_parent ($child_iter), 'Gtk3::TreeIter');
}

# Gtk3::TreeModelFilter
SKIP: {
  skip 'tree model ctors not properly supported', 3
    unless check_gi_version(1, 29, 17);

  my $child_model = Gtk3::TreeStore->new ([qw/Glib::String/]);
  my $child_iter = $child_model->append (undef);
  $child_model->set ($child_iter, 0 => 'Bla');
  my $model = Gtk3::TreeModelFilter->new ($child_model);
  isa_ok ($model, 'Gtk3::TreeModelFilter');
  my $iter = $model->convert_child_iter_to_iter ($child_iter);
  isa_ok ($iter, 'Gtk3::TreeIter');
  is ($model->get ($iter, 0), 'Bla');
}

# Gtk3::TreeModelSort
SKIP: {
  skip 'tree model ctors not properly supported', 3
    unless check_gi_version(1, 29, 17);

  my $child_model = Gtk3::TreeStore->new ([qw/Glib::String/]);
  my $child_iter = $child_model->append (undef);
  $child_model->set ($child_iter, 0 => 'Bla');
  my $model = Gtk3::TreeModelSort->new_with_model ($child_model);
  isa_ok ($model, 'Gtk3::TreeModelSort');
  my $iter = $model->convert_child_iter_to_iter ($child_iter);
  isa_ok ($iter, 'Gtk3::TreeIter');
  is ($model->get ($iter, 0), 'Bla');
}

# Gtk3::TreeSelection::get_selected
SKIP: {
  skip 'tree model ctors not properly supported', 2
    unless check_gi_version(1, 29, 17);

  my $model = Gtk3::ListStore->new ('Glib::String');
  my $view = Gtk3::TreeView->new ($model);
  my $selection = $view->get_selection;
  my $iter = $model->append;
  $selection->select_iter ($iter);
  my ($sel_model, $sel_iter) = $selection->get_selected;
  is ($sel_model, $model);
  isa_ok ($sel_iter, 'Gtk3::TreeIter');
}

# Gtk3::Gdk::Window::new
SKIP: {
  # https://bugzilla.gnome.org/show_bug.cgi?id=670369
  skip 'window attr type annotation missing', 3
    unless Gtk3::CHECK_VERSION (3, 6, 0);

  my $window = Gtk3::Gdk::Window->new (undef, {
    window_type => 'toplevel',
  });
  isa_ok ($window, 'Gtk3::Gdk::Window');

  $window = Gtk3::Gdk::Window->new (undef, {
    window_type => 'toplevel',
    width => 100, height => 50,
    x => 100, y => 50,
  }, [qw/x y/]);
  isa_ok ($window, 'Gtk3::Gdk::Window');

  $window = Gtk3::Gdk::Window->new (undef, {
    window_type => 'toplevel',
    width => 100, height => 50,
    x => 100, y => 50,
  });
  isa_ok ($window, 'Gtk3::Gdk::Window');
}

# Gtk3::Gdk::Pixbuf::get_formats
{
  my @formats = Gtk3::Gdk::Pixbuf->get_formats;
  isa_ok (ref $formats[0], 'Gtk3::Gdk::PixbufFormat');
}

# Gtk3::Gdk::Pixbuf::save, save_to_buffer, save_to_callback
SKIP: {
  # FIXME: https://bugzilla.gnome.org/show_bug.cgi?id=670372
  skip 'save & save_to_buffer annotations missing', 7;

  my ($width, $height) = (45, 89);
  my $data = pack "C*", map { int rand 255 } 0..(3*$width*$height);
  my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_data
    ($data, 'rgb', Glib::FALSE, 8, $width, $height, $width*3);

  my $filename = 'testsave.png';
  eval {
    $pixbuf->save ($filename, 'png',
                   'key_arg_without_value_arg');
  };
  like ($@, qr/Usage/);
  my $mtime = scalar localtime;
  my $desc = 'Something really cool';
  $pixbuf->save ($filename, 'png',
                 'tEXt::Thumb::MTime' => $mtime,
                 'tEXt::Description' => $desc);
  my $new_pixbuf = Gtk3::Gdk::Pixbuf->new_from_file ($filename);
  isa_ok ($new_pixbuf, 'Gtk3::Gdk::Pixbuf', 'new_from_file');
  is ($new_pixbuf->get_option ('tEXt::Description'), $desc);
  is ($new_pixbuf->get_option ('tEXt::Thumb::MTime'), $mtime);
  unlink $filename;

  my $buffer = eval {
    $pixbuf->save_to_buffer ('jpeg', [qw/quality/], [0.75]);
    $pixbuf->save_to_buffer ('jpeg', quality => 0.75);
  } || eval {
    $pixbuf->save_to_buffer ('png'); # fallback if jpeg not supported
  };
  ok (defined $buffer, 'save_to_buffer');
  my $loader = Gtk3::Gdk::PixbufLoader->new;
  $loader->write ($buffer);
  $loader->close;
  $new_pixbuf = $loader->get_pixbuf;
  is ($new_pixbuf->get_width, $width);
  is ($new_pixbuf->get_height, $height);

  # FIXME: callbacks with automatic args not supported yet.
  # $pixbuf->save_to_callback (sub { warn @_; return Glib::TRUE; }, 'data', 'png');
}
