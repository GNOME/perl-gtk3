#!/usr/bin/perl

# Originally copied from Gtk2/t/GtkTextBuffer.t.

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;
use utf8;
use Glib qw/TRUE FALSE/;

plan tests => 40;

my $table = Gtk3::TextTagTable -> new();

my $buffer = Gtk3::TextBuffer -> new($table);
isa_ok($buffer, "Gtk3::TextBuffer");
is($buffer -> get_tag_table(), $table);

$buffer = Gtk3::TextBuffer -> new();
isa_ok($buffer, "Gtk3::TextBuffer");

isa_ok($buffer -> get_start_iter(), "Gtk3::TextIter");
isa_ok($buffer -> get_end_iter(), "Gtk3::TextIter");

$buffer -> set_modified(FALSE);

# Use one multi-byte character to test length handling.
my $text = "Lore ipsem dolor‽  I think that is misspelled.\n";
my $start = sub { $buffer -> get_start_iter() };
my $end = sub { $buffer -> get_end_iter() };
my $bounds = sub { $buffer -> get_bounds() };

$buffer -> insert($start->(), $text);
ok($buffer -> insert_interactive($start->(), $text, TRUE));
$buffer -> insert_at_cursor($text);
ok($buffer -> insert_interactive_at_cursor($text, TRUE));
$buffer -> insert_range($end->(), $bounds->());
ok($buffer -> insert_range_interactive($end->(), $bounds->(), TRUE));

my @tags = ($buffer -> create_tag("bla", indent => 2),
            $buffer -> create_tag("blub", indent => 2));

$buffer -> create_tag("blaa", indent => 2);
$buffer -> create_tag("bluub", indent => 2);

$buffer -> insert_with_tags($start->(), $text, @tags);
$buffer -> insert_with_tags_by_name($start->(), $text, "blaa", "bluub");

is($buffer -> get_text($bounds->(), TRUE), $text x 18);
is($buffer -> get_line_count(), 18+1);
is($buffer -> get_char_count(), 18 * length $text);
ok($buffer -> get_modified());

isa_ok($buffer -> get_iter_at_line_offset(1, 10), "Gtk3::TextIter");
isa_ok($buffer -> get_iter_at_offset(100), "Gtk3::TextIter");
isa_ok($buffer -> get_iter_at_line(6), "Gtk3::TextIter");
isa_ok($buffer -> get_iter_at_line_index(3, 12), "Gtk3::TextIter");

my ($start_iter, $end_iter) = $buffer -> get_bounds();
isa_ok($start_iter, "Gtk3::TextIter");
isa_ok($end_iter, "Gtk3::TextIter");

$buffer -> set_text($text);
is($buffer -> get_text($bounds->(), TRUE), $text);
is($buffer -> get_slice($bounds->(), TRUE), $text);

$buffer -> delete($bounds->());
ok($buffer -> delete_interactive($bounds->(), TRUE));

$buffer -> insert_pixbuf($start->(), Gtk3::Gdk::Pixbuf -> new("rgb", 0, 8, 10, 10));

my $anchor = Gtk3::TextChildAnchor -> new();
$buffer -> insert_child_anchor($start->(), $anchor);

isa_ok($buffer -> get_iter_at_child_anchor($anchor), "Gtk3::TextIter");

isa_ok($buffer -> create_child_anchor($start->()), "Gtk3::TextChildAnchor");

my $mark = $buffer -> create_mark("bla", $start->(), TRUE);
isa_ok($mark, "Gtk3::TextMark");
is($buffer -> get_mark("bla"), $mark);

isa_ok($buffer -> get_iter_at_mark($mark), "Gtk3::TextIter");

$buffer -> move_mark($mark, $end->());
$buffer -> move_mark_by_name("bla", $start->());
$buffer -> delete_mark($mark);

$mark = $buffer -> create_mark("bla", $start->(), TRUE);
$buffer -> delete_mark_by_name("bla");

isa_ok($buffer -> get_insert(), "Gtk3::TextMark");
isa_ok($buffer -> get_selection_bound(), "Gtk3::TextMark");

$buffer -> place_cursor($end->());

ok(!$buffer -> delete_selection(TRUE, TRUE));
ok(!$buffer -> get_selection_bounds());

{
  $buffer -> select_range($bounds->());
}

my $tag_one = $buffer -> create_tag("alb", indent => 2, justification => 'center');
isa_ok($tag_one, "Gtk3::TextTag");
is($tag_one->get ('indent'), 2);
is($tag_one->get ('justification'), 'center');

$buffer -> apply_tag($tag_one, $bounds->());
$buffer -> apply_tag_by_name("alb", $bounds->());

my $tag_two = $buffer -> create_tag("bulb", indent => 2);
my $tag_three = $buffer -> create_tag(undef, indent => 2);
isa_ok($tag_two, "Gtk3::TextTag");
isa_ok($tag_three, "Gtk3::TextTag");

$buffer -> remove_tag($tag_one, $bounds->());
$buffer -> remove_tag_by_name("bulb", $bounds->());
$buffer -> remove_all_tags($bounds->());

SKIP: {
  skip 'clipboard stuff; missing annotations', 0
    unless Gtk3::CHECK_VERSION (3, 2, 0);

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

{
  $buffer -> backspace($end->(), TRUE, TRUE);
}

{
  my $bool = $buffer -> get_has_selection();
  ok (1);

  my $targetlist = $buffer -> get_copy_target_list();
  isa_ok($targetlist, 'Gtk3::TargetList');
  $targetlist = $buffer -> get_paste_target_list();
  isa_ok($targetlist, 'Gtk3::TargetList');

  isa_ok($buffer -> get('copy-target-list'), 'Gtk3::TargetList');
  isa_ok($buffer -> get('paste-target-list'), 'Gtk3::TargetList');
}

{
  my $mark = Gtk3::TextMark -> new('bla', TRUE);
  $buffer -> add_mark($mark, $end->());
}
