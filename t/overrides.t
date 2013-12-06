#!/usr/bin/env perl

BEGIN { require './t/inc/setup.pl' };

use strict;
use warnings;
use utf8;
use Encode;

plan tests => 164;

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

# Gtk3::[HV]Box
{
  foreach my $class (qw/HBox VBox/) {
    my $box = "Gtk3::$class"->new;
    ok (!$box->get_homogeneous);
    is ($box->get_spacing, 5);
  }
}

# Gtk3::Button::new
{
  my $button = Gtk3::Button->new;
  ok (!defined ($button->get_label));
  $button = Gtk3::Button->new ('_Test');
  is ($button->get_label, '_Test');
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

# Gtk3::CheckButton::new
{
  my $button = Gtk3::CheckButton->new;
  ok (!defined ($button->get_label));
  $button = Gtk3::CheckButton->new ('_Test');
  is ($button->get_label, '_Test');
}

# Gtk3::ColorButton::new
{
  my $button = Gtk3::ColorButton->new;
  is ($button->get_color->red, 0);
  my $color = Gtk3::Gdk::Color->new (red => 2**16-1, green => 0, blue => 0);
  $button = Gtk3::ColorButton->new ($color);
  is ($button->get_color->red, $color->red);
}

# Gtk3::CssProvider
SKIP: {
  skip 'Gtk3::CssProvider; incorrect annotations', 2
    unless Gtk3::CHECK_VERSION (3, 2, 0);

  my $css = "GtkButton {font: Cantarelll 10}";
  my $expect = qr/Cantarelll/;
  my $p = Gtk3::CssProvider->new;

  $p->load_from_data ($css);
  like ($p->to_string, $expect);

  $p->load_from_data ([unpack 'C*', $css]);
  like ($p->to_string, $expect);
}

# Gtk3::Editable::insert_text
{
  my $entry = Gtk3::Entry->new;
  my $orig_text = 'aeiou';
  my $orig_text_chars = length ($orig_text);
  my $orig_text_bytes = length (Encode::encode_utf8 ($orig_text));
  $entry->set_text ($orig_text);
  my ($new_text, $pos) = ('0123456789', $orig_text_chars);
  my $new_text_chars = length ($new_text);
  my $new_text_bytes = length (Encode::encode_utf8 ($new_text));
  is ($entry->insert_text ($new_text, $pos),
      $pos + $new_text_chars);
  $pos = 0;
  is ($entry->insert_text ($new_text, $new_text_bytes, $pos),
      $pos + $new_text_chars);
  is ($entry->get_text, $new_text . $orig_text . $new_text);
}

# Gtk3::Editable::insert_text and length issues
{
  my $entry = Gtk3::Entry->new;
  my ($text, $pos) = ('0123456789€', 0);
  is ($entry->insert_text ($text, $pos),
      $pos + length ($text));
  is ($entry->get_text, $text);
}

# GtkEditable.insert-text signal
SKIP: {
  skip 'GtkEditable.insert-text signal; need generic signal marshaller', 5
    unless check_gi_version (1, 33, 10);

  my $entry = Gtk3::Entry->new;
  my $orig_text = 'äöü';
  $entry->set_text ($orig_text);

  my ($my_text, $my_pos) = ('123', 2);
  $entry->signal_connect ('insert-text' => sub {
    my ($entry, $new_text, $new_text_bytes, $position, $data) = @_;
    is ($new_text, $my_text);
    is ($new_text_bytes, length (Encode::encode_utf8 ($my_text)));
    is ($position, $my_pos);
    # Disregard $position and move the text to the end.
    return length $entry->get_text;
  });
  is ($entry->insert_text ($my_text, $my_pos),
      length ($orig_text) + length ($my_text));
  is ($entry->get_text, $orig_text . $my_text);
}

# Gtk3::FileChooserDialog
{
  my $parent = Gtk3::Window->new;
  my $dialog = Gtk3::FileChooserDialog->new ('some title', $parent, 'save',
                                             'gtk-cancel' => 'cancel',
                                             'gtk-ok' => 23);
  is ($dialog->get_title, 'some title');
  is ($dialog->get_transient_for, $parent);
  is ($dialog->get_action, 'save');
}

# Gtk3::FontButton::new
{
  my $button = Gtk3::FontButton->new;
  # $button->get_font_name can be anything
  $button = Gtk3::FontButton->new ('Sans');
  ok (defined $button->get_font_name);
}

# Gtk3::LinkButton::new
{
  my ($host, $label) = ('http://localhost', 'Local');
  my $button = Gtk3::LinkButton->new ($host);
  is ($button->get_label, $host);
  $button = Gtk3::LinkButton->new ($host, $label);
  is ($button->get_label, $label);
}

# Gtk3::ListStore::new, set and get, insert_with_values
SKIP: {
  skip 'Gtk3::ListStore; tree model ctors not properly supported', 10
    unless check_gi_version(1, 29, 17);

  my $model = Gtk3::ListStore->new ([qw/Glib::String Glib::Int/]);
  my $iter = $model->append;
  $model->set ($iter, [0, 1], ['Foo', 23]);
  is_deeply ([$model->get ($iter)], ['Foo', 23]);
  is_deeply ([$model->get ($iter, 0,1)], ['Foo', 23]);
  is (scalar $model->get ($iter, 0,1), 23);

  $iter = $model->append;
  $model->set ($iter, 0 => 'Bar', 1 => 42);
  is_deeply ([$model->get ($iter)], ['Bar', 42]);
  is_deeply ([$model->get ($iter, 0,1)], ['Bar', 42]);
  is (scalar $model->get ($iter, 0,1), 42);

  {
    local $@;
    eval { $model->set ($iter, 0) };
    like ($@, qr/Usage/);
  }

  $iter = $model->insert_with_values (-1, [0, 1], ['FooFoo', 2323]);
  is_deeply ([$model->get ($iter)], ['FooFoo', 2323]);
  $iter = $model->insert_with_values (-1, 0 => 'BarBar', 1 => 4242);
  is_deeply ([$model->get ($iter)], ['BarBar', 4242]);

  {
    local $@;
    eval { $model->insert_with_values (-1, 0); };
    like ($@, qr/Usage/);
  }
}

# Gtk3::Menu::popup and popup_for_device
SKIP: {
  skip 'Gtk3::Menu; incorrect annotations', 2
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

# Gtk3::SizeGroup
{
  my $group = Gtk3::SizeGroup->new ("vertical");

  my @widgets = $group->get_widgets;
  ok (!@widgets);

  my ($uno, $dos, $tres, $cuatro) =
    (Gtk3::Label->new ("Tinky-Winky"),
     Gtk3::Label->new ("Dipsy"),
     Gtk3::Label->new ("La La"),
     Gtk3::Label->new ("Po"));

  $group->add_widget ($uno);
  $group->add_widget ($dos);
  $group->add_widget ($tres);
  $group->add_widget ($cuatro);
  @widgets = $group->get_widgets;
  is (scalar @widgets, 4);
}

# Gtk3::Stock
{
  ok (grep { $_ eq 'gtk-ok' } Gtk3::Stock::list_ids ());
  my $item = Gtk3::Stock::lookup ('gtk-ok');
  is ($item->{stock_id}, 'gtk-ok');
  # Gtk3::Stock::add and add_static don't work yet
  Gtk3::Stock::set_translate_func ('perl-domain', sub {}, 42);
}

# Gtk3::ToggleButton::new
{
  my $button = Gtk3::ToggleButton->new;
  ok (!defined ($button->get_label));
  $button = Gtk3::ToggleButton->new ('_Test');
  is ($button->get_label, '_Test');
}

# Gtk3::TreeStore::new, set and get, insert_with_values
SKIP: {
  skip 'Gtk3::TreeStore; tree model ctors not properly supported', 10
    unless check_gi_version(1, 29, 17);

  my $model = Gtk3::TreeStore->new ([qw/Glib::String Glib::Int/]);
  my $iter = $model->append (undef);
  $model->set ($iter, [0, 1], ['Foo', 23]);
  is_deeply ([$model->get ($iter)], ['Foo', 23]);
  is_deeply ([$model->get ($iter, 0,1)], ['Foo', 23]);
  is (scalar $model->get ($iter, 0,1), 23);

  $iter = $model->append (undef);
  $model->set ($iter, 0 => 'Bar', 1 => 42);
  is_deeply ([$model->get ($iter)], ['Bar', 42]);
  is_deeply ([$model->get ($iter, 0,1)], ['Bar', 42]);
  is (scalar $model->get ($iter, 0,1), 42);

  {
    local $@;
    eval { $model->set ($iter, 0) };
    like ($@, qr/Usage/);
  }

  $iter = $model->insert_with_values (undef, -1, [0, 1], ['FooFoo', 2323]);
  is_deeply ([$model->get ($iter)], ['FooFoo', 2323]);
  $iter = $model->insert_with_values (undef, -1, 0 => 'BarBar', 1 => 4242);
  is_deeply ([$model->get ($iter)], ['BarBar', 4242]);

  {
    local $@;
    eval { $model->insert_with_values (undef, -1, 0); };
    like ($@, qr/Usage/);
  }
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
  skip 'Gtk3::TreeModel; tree model ctors not properly supported', 6
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
  skip 'Gtk3::TreeModel; tree model ctors not properly supported', 6
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
  skip 'Gtk3::TreeFilter; tree model ctors not properly supported', 3
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
  skip 'Gtk3::TreeModelSort; tree model ctors not properly supported', 3
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
  skip 'Gtk3::TreeSelection; tree model ctors not properly supported', 3
    unless check_gi_version(1, 29, 17);

  my $model = Gtk3::ListStore->new ('Glib::String');
  my $view = Gtk3::TreeView->new ($model);
  my $selection = $view->get_selection;
  my $iter = $model->append;
  $selection->select_iter ($iter);
  my ($sel_model, $sel_iter) = $selection->get_selected;
  is ($sel_model, $model);
  isa_ok ($sel_iter, 'Gtk3::TreeIter');
  $sel_iter = $selection->get_selected;
  isa_ok ($sel_iter, 'Gtk3::TreeIter');
}

# Gtk3::TreeView::insert_column_with_attributes, get_dest_row_at_pos,
# get_path_at_pos, get_tooltip_context, get_visible_range
SKIP: {
  skip 'Gtk3::TreeView; tree model ctors not properly supported', 5
    unless check_gi_version(1, 29, 17);

  my $model = Gtk3::ListStore->new ('Glib::String');
  $model->insert_with_values (-1, 0 => 'Test string');

  my $view = Gtk3::TreeView->new ($model);
  $view->insert_column_with_attributes (-1, 'String',
                                        Gtk3::CellRendererText->new,
                                        text => 0);
  my $column = $view->get_column (0);
  is ($column->get_title, 'String');
  is_deeply ([$view->get_columns], [$column]);

  my $window = Gtk3::Window->new;
  $window->add ($view);
  $window->show_all;

  my @bin_pos = (0, 0);
  my @widget_pos = $view->convert_bin_window_to_widget_coords (@bin_pos);
  my @dest_stuff = $view->get_dest_row_at_pos (@widget_pos);
  is (@dest_stuff, 2);
  my @pos_stuff = $view->get_path_at_pos (@bin_pos);
  is (@pos_stuff, 4);

  my @tooltip_stuff = $view->get_tooltip_context (@widget_pos, Glib::TRUE);
  is (@tooltip_stuff, 5);

  # Nondeterministic:
  my @vis_paths = $view->get_visible_range;
  # is (@vis_paths, 2); # or sometimes 0
}

# Gtk3::TreeViewColumn::new_with_attributes, set_attributes, cell_get_position
SKIP: {
  skip 'Gtk3::TreeViewColumn; tree model ctors not properly supported', 2
    unless check_gi_version(1, 29, 17);

  my $model = Gtk3::ListStore->new ('Glib::String');
  $model->insert_with_values (-1, 0 => 'Test string');

  my $renderer = Gtk3::CellRendererText->new;
  my $column = Gtk3::TreeViewColumn->new_with_attributes (
    'String', $renderer, text => 0);
  is ($column->get_title, 'String');
  $column->set_attributes ($renderer, text => 0);

  my $view = Gtk3::TreeView->new ($model);
  $view->insert_column ($column, -1);

  my $window = Gtk3::Window->new;
  $window->add ($view);
  $window->show_all;

  my @cell_stuff = $column->cell_get_position ($renderer);
  is (@cell_stuff, 2);
}

# Gtk3::UIManager
{
  my $ui_manager = Gtk3::UIManager->new;
  my $ui_info = <<__EOD__;
<ui>
  <menubar name='MenuBar'>
    <menu action='HelpMenu'>
      <menuitem action='About'/>
    </menu>
  </menubar>
  <menubar name='MenuBla'>
    <menu action='HelpMenu'>
      <menuitem action='License'/>
    </menu>
  </menubar>
</ui>
__EOD__
  ok ($ui_manager->add_ui_from_string ($ui_info) != 0);

  my $group_one = Gtk3::ActionGroup->new ("Barney");
  my $group_two = Gtk3::ActionGroup->new ("Fred");
  my @entries = (
    [ "HelpMenu", undef, "_Help" ],
    [ "About", undef, "_About", "<control>A", "About" ],
    [ "License", undef, "_License", "<control>L", "License" ],
  );
  $group_one->add_actions (\@entries, undef);
  $ui_manager->insert_action_group ($group_one, 0);
  $ui_manager->insert_action_group ($group_two, 1);
  is_deeply ([$ui_manager->get_action_groups], [$group_one, $group_two]);

  $ui_manager->ensure_update;
  my @menubars = $ui_manager->get_toplevels ("menubar");
  is (@menubars, 2);
  isa_ok ($menubars[0], "Gtk3::MenuBar");
  isa_ok ($menubars[1], "Gtk3::MenuBar");
}

# Gtk3::Widget
{
  my $widget = Gtk3::Label->new ("Test");
  isa_ok ($widget->render_icon ("gtk-open", "menu", "detail"),
          "Gtk3::Gdk::Pixbuf");
}

# Gtk3::Gdk::Atom
SKIP: {
  skip 'atom stuff; missing annotations', 2
    unless Gtk3::CHECK_VERSION(3, 2, 0);
  my $atom1 = Gtk3::Gdk::Atom::intern("CLIPBOARD", Glib::FALSE);
  my $atom2 = Gtk3::Gdk::Atom::intern("CLIPBOARD", Glib::FALSE);
  my $atom3 = Gtk3::Gdk::Atom::intern("PRIMARY", Glib::FALSE);
  ok ($atom1 == $atom2);
  ok ($atom1 != $atom3);
}

# Gtk3::Gdk::RGBA
{
  my $rgba = Gtk3::Gdk::RGBA->new ({red => 0.0, green => 0.5, blue => 0.5, alpha => 0.5});
  isa_ok ($rgba, 'Gtk3::Gdk::RGBA');
  is ($rgba->red, 0.0);

  $rgba = Gtk3::Gdk::RGBA->new (red => 0.5, green => 0.0, blue => 0.5, alpha => 0.5);
  isa_ok ($rgba, 'Gtk3::Gdk::RGBA');
  is ($rgba->green, 0.0);

  $rgba = Gtk3::Gdk::RGBA->new (0.5, 0.5, 0.0, 0.5);
  isa_ok ($rgba, 'Gtk3::Gdk::RGBA');
  is ($rgba->blue, 0.0);

  $rgba = Gtk3::Gdk::RGBA::parse ('rgba(0.5, 0.5, 0.5, 0.0)');
  isa_ok ($rgba, 'Gtk3::Gdk::RGBA');
  is ($rgba->alpha, 0.0);

  ok ($rgba->parse ('rgba(0.5, 0.5, 0.5, 1.0)'));
  is ($rgba->alpha, 1.0);
}

# Gtk3::Gdk::Window::new
SKIP: {
  # https://bugzilla.gnome.org/show_bug.cgi?id=670369
  skip 'Gtk3::Gdk::Window::new; window attr type annotation missing', 3
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
  my @formats = Gtk3::Gdk::Pixbuf::get_formats;
  isa_ok ($formats[0], 'Gtk3::Gdk::PixbufFormat');
}

# Gtk3::Gdk::Pixbuf::new_from_data
SKIP: {
  skip 'Gtk3::Gdk::Pixbuf::new_from_data; incorrect annotations', 2;

  my ($width, $height) = (45, 89);
  my ($r, $g, $b) = (255, 0, 255);
  my $data = pack 'C*', (($r, $g, $b) x ($width*$height));
  my $pixbuf = Gtk3::Gdk::Pixbuf->new_from_data
    ($data, 'rgb', Glib::FALSE, 8, $width, $height, $width*3);
  is ($pixbuf->get_byte_length, 3*$width*$height);
  is ($pixbuf->get_pixels, $data);
}

# Gtk3::Gdk::Pixbuf::save, save_to_buffer, save_to_callback
SKIP: {
  skip 'pixbuf stuff; missing annotations', 19
    unless Gtk3::Gdk::PIXBUF_MINOR >= 25;

  my ($width, $height) = (10, 5);
  my $pixbuf = Gtk3::Gdk::Pixbuf->new ('rgb', Glib::TRUE, 8, $width, $height);
  $pixbuf->fill (hex '0xFF000000');
  my $expected_pixels = $pixbuf->get_pixels;

  my $filename = 'testsave.png';
  END { unlink $filename if defined $filename; }
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
  is ($new_pixbuf->get_width, $width);
  is ($new_pixbuf->get_height, $height);
  is ($new_pixbuf->get_pixels, $expected_pixels);

  my $buffer = do {
    $pixbuf->save_to_buffer ('png', [qw/compression/], [9]);
    $pixbuf->save_to_buffer ('png', compression => 9);
    $pixbuf->save_to_buffer ('png');
  };
  ok (defined $buffer, 'save_to_buffer');
  my $loader = Gtk3::Gdk::PixbufLoader->new;
  $loader->write ($buffer);
  $loader->close;
  $new_pixbuf = $loader->get_pixbuf;
  is ($new_pixbuf->get_width, $width);
  is ($new_pixbuf->get_height, $height);
  is ($new_pixbuf->get_pixels, $expected_pixels);

  my $callback_buffer = [];
  my $invocation_count = 0;
  ok ($pixbuf->save_to_callback (sub {
    my ($pixels, $length, $data) = @_;
    if (0 == $invocation_count++) {
      is ($length, scalar @$pixels);
      is ($pixels->[0], 137); is ($pixels->[7], 10); # PNG header
      is ($data, 'data');
    }
    push @$callback_buffer, @$pixels;
    return Glib::TRUE, undef;
  }, 'data', 'png'));
  is_deeply ($callback_buffer, $buffer);

  skip 'Gtk3::Gdk::Pixbuf::save_to_callback; need error domain support', 2
    unless check_gi_version (1, 29, 17);
  eval {
    $pixbuf->save_to_callback (sub {
      return Glib::FALSE, Gtk3::Gdk::PixbufError->new ('insufficient-memory', 'buzz');
    }, undef, 'png');
  };
  my $error = $@;
  isa_ok ($error, 'Glib::Error');
  is ($error->message, 'buzz');
}

# Pango::Layout
{
  my $label = Gtk3::Label->new ('Bla');
  my $layout = $label->create_pango_layout ('Bla');

  $layout->set_text('Bla bla.', 3);
  is ($layout->get_text, 'Bla');

  $layout->set_text('Bla bla.');
  is ($layout->get_text, 'Bla bla.');
}
