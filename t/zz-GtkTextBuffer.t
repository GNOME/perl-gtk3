#!/usr/bin/perl

# Originally copied from Gtk2/t/GtkTextBuffer.t.

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;
use Glib qw/TRUE FALSE/;

plan tests => 37;

my $table = Gtk3::TextTagTable -> new();

my $buffer = Gtk3::TextBuffer -> new($table);
isa_ok($buffer, "Gtk3::TextBuffer");
is($buffer -> get_tag_table(), $table);

$buffer = Gtk3::TextBuffer -> new();
isa_ok($buffer, "Gtk3::TextBuffer");

isa_ok($buffer -> get_start_iter(), "Gtk3::TextIter");
isa_ok($buffer -> get_end_iter(), "Gtk3::TextIter");

$buffer -> set_modified(FALSE);

$buffer -> insert($buffer -> get_start_iter(), "Lore ipsem dolor.  I think that is misspelled.\n");
ok($buffer -> insert_interactive($buffer -> get_start_iter(), "Lore ipsem dolor.  I think that is misspelled.\n", TRUE));
$buffer -> insert_at_cursor("Lore ipsem dolor.  I think that is misspelled.\n");
ok($buffer -> insert_interactive_at_cursor("Lore ipsem dolor.  I think that is misspelled.\n", TRUE));
$buffer -> insert_range($buffer -> get_end_iter(), $buffer -> get_iter_at_offset(141), $buffer -> get_end_iter());
ok($buffer -> insert_range_interactive($buffer -> get_end_iter(), $buffer -> get_iter_at_offset(188), $buffer -> get_end_iter(), TRUE));

my @tags = ($buffer -> create_tag("bla", indent => 2),
            $buffer -> create_tag("blub", indent => 2));

$buffer -> create_tag("blaa", indent => 2);
$buffer -> create_tag("bluub", indent => 2);

$buffer -> insert_with_tags($buffer -> get_start_iter(), "Lore ipsem dolor.  I think that is misspelled.\n", @tags);
$buffer -> insert_with_tags_by_name($buffer -> get_start_iter(), "Lore ipsem dolor.  I think that is misspelled.\n", "blaa", "bluub");

is($buffer -> get_line_count(), 9);
is($buffer -> get_char_count(), 376);
ok($buffer -> get_modified());

isa_ok($buffer -> get_iter_at_line_offset(1, 10), "Gtk3::TextIter");
isa_ok($buffer -> get_iter_at_offset(100), "Gtk3::TextIter");
isa_ok($buffer -> get_iter_at_line(6), "Gtk3::TextIter");
isa_ok($buffer -> get_iter_at_line_index(3, 12), "Gtk3::TextIter");

my ($start, $end) = $buffer -> get_bounds();
isa_ok($start, "Gtk3::TextIter");
isa_ok($end, "Gtk3::TextIter");

$buffer -> set_text("Lore ipsem dolor.  I think that is misspelled.\n");
is($buffer -> get_text($buffer -> get_start_iter(), $buffer -> get_end_iter(), TRUE), "Lore ipsem dolor.  I think that is misspelled.\n");
is($buffer -> get_slice($buffer -> get_start_iter(), $buffer -> get_end_iter(), TRUE), "Lore ipsem dolor.  I think that is misspelled.\n");

$buffer -> delete($buffer -> get_start_iter(), $buffer -> get_end_iter());
ok($buffer -> delete_interactive($buffer -> get_start_iter(), $buffer -> get_end_iter(), TRUE));

$buffer -> insert_pixbuf($buffer -> get_start_iter(), Gtk3::Gdk::Pixbuf -> new("rgb", 0, 8, 10, 10));

my $anchor = Gtk3::TextChildAnchor -> new();
$buffer -> insert_child_anchor($buffer -> get_start_iter(), $anchor);

isa_ok($buffer -> get_iter_at_child_anchor($anchor), "Gtk3::TextIter");

isa_ok($buffer -> create_child_anchor($buffer -> get_start_iter()), "Gtk3::TextChildAnchor");

my $mark = $buffer -> create_mark("bla", $buffer -> get_start_iter(), TRUE);
isa_ok($mark, "Gtk3::TextMark");
is($buffer -> get_mark("bla"), $mark);

isa_ok($buffer -> get_iter_at_mark($mark), "Gtk3::TextIter");

$buffer -> move_mark($mark, $buffer -> get_end_iter());
$buffer -> move_mark_by_name("bla", $buffer -> get_start_iter());
$buffer -> delete_mark($mark);

$mark = $buffer -> create_mark("bla", $buffer -> get_start_iter(), TRUE);
$buffer -> delete_mark_by_name("bla");

isa_ok($buffer -> get_insert(), "Gtk3::TextMark");
isa_ok($buffer -> get_selection_bound(), "Gtk3::TextMark");

$buffer -> place_cursor($buffer -> get_end_iter());

ok(!$buffer -> delete_selection(TRUE, TRUE));
ok(!$buffer -> get_selection_bounds());

SKIP: {
  $buffer -> select_range($buffer -> get_start_iter(), $buffer -> get_end_iter());
}

my $tag_one = $buffer -> create_tag("alb", indent => 2);
isa_ok($tag_one, "Gtk3::TextTag");

$buffer -> apply_tag($tag_one, $buffer -> get_start_iter(), $buffer -> get_end_iter());
$buffer -> apply_tag_by_name("alb", $buffer -> get_start_iter(), $buffer -> get_end_iter());

my $tag_two = $buffer -> create_tag("bulb", indent => 2);
my $tag_three = $buffer -> create_tag(undef, indent => 2);
isa_ok($tag_two, "Gtk3::TextTag");
isa_ok($tag_three, "Gtk3::TextTag");

$buffer -> remove_tag($tag_one, $buffer -> get_start_iter(), $buffer -> get_end_iter());
$buffer -> remove_tag_by_name("bulb", $buffer -> get_start_iter(), $buffer -> get_end_iter());
$buffer -> remove_all_tags($buffer -> get_start_iter(), $buffer -> get_end_iter());

SKIP: {
  my $clipboard = Gtk3::Clipboard::get(Gtk3::Gdk::Atom::intern('clipboard', Glib::FALSE));

  $buffer -> paste_clipboard($clipboard, $buffer -> get_end_iter(), TRUE);
  $buffer -> paste_clipboard($clipboard, undef, TRUE);
  $buffer -> copy_clipboard($clipboard);
  $buffer -> cut_clipboard($clipboard, TRUE);

  $buffer -> add_selection_clipboard($clipboard);
  $buffer -> remove_selection_clipboard($clipboard);
}

$buffer -> begin_user_action();
$buffer -> end_user_action();

SKIP: {
  $buffer -> backspace($buffer -> get_end_iter(), TRUE, TRUE);
}

SKIP: {
  my $bool = $buffer -> get_has_selection();
  ok (1);

  my $targetlist = $buffer -> get_copy_target_list();
  isa_ok($targetlist, 'Gtk3::TargetList');
  $targetlist = $buffer -> get_paste_target_list();
  isa_ok($targetlist, 'Gtk3::TargetList');

  isa_ok($buffer -> get('copy-target-list'), 'Gtk3::TargetList');
  isa_ok($buffer -> get('paste-target-list'), 'Gtk3::TargetList');
}

SKIP: {
  my $mark = Gtk3::TextMark -> new('bla', TRUE);
  my $iter = $buffer -> get_end_iter();
  $buffer -> add_mark($mark, $iter);
}
