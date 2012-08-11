#!/usr/bin/perl

# Originally copied from Gtk2/t/GdkEvent.t.

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;

plan tests => 144;

sub fields_ok {
  my ($event, %fields_values) = @_;
  foreach my $field (keys %fields_values) {
    field_ok ($event, $field, $fields_values{$field});
  }
}

sub field_ok {
  my ($event, $field, $value) = @_;
  $event->$field ($value);
  is ($event->$field, $value);
}

# Any #########################################################################

isa_ok (my $event = Gtk3::Gdk::Event->new ('enter-notify'),
	'Gtk3::Gdk::Event', 'Gtk3::Gdk::Event->new any');

isa_ok ($event->copy, 'Gtk3::Gdk::Event');

is ($event->type, 'enter-notify');

my $window = Gtk3::Gdk::Window->new (undef, {
			width => 20,
			height => 20,
			wclass => 'input-output',
			window_type => 'toplevel'
		});
field_ok ($event, window => $window);
field_ok ($event, window => undef);
field_ok ($event, send_event => 23);

my $screen = Gtk3::Gdk::Screen->get_default;
$event->set_screen ($screen);
is ($event->get_screen, $screen, '$event->get_screen');

my $device = Gtk3::Gdk::Display::get_default->list_devices->[0]; # FIXME?
$event->set_device ($device);
is ($event->get_device, $device, '$event->get_device');

$event->set_source_device ($device);
is ($event->get_source_device, $device, '$event->get_source_device');

# Expose #######################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('expose'),
	'Gtk3::Gdk::EventExpose', 'Gtk3::Gdk::Event->new expose');

field_ok ($event, count => 10);

my $rect = {x => 0, y => 0, width => 100, height => 100}; # FIXME: [0, 0, 100, 100]
$event->area ($rect);
is_deeply ($event->area, $rect, '$expose_event->area');

my $region = Cairo::Region->create ($rect);
$event->region ($region);
isa_ok ($event->region, 'Cairo::Region', '$expose_event->region');
is_deeply ($event->region->get_rectangle (0), $rect);
$event->region (undef);
is ($event->region, undef, '$expose_event->region undef');

# Visibility ###################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('visibility-notify'),
	'Gtk3::Gdk::EventVisibility', 'Gtk3::Gdk::Event->new visibility');

field_ok ($event, state => 'partial');

# Motion #######################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('motion-notify'),
	'Gtk3::Gdk::EventMotion', 'Gtk3::Gdk::Event->new motion');

fields_ok ($event, time => 42,
                   x => 13,
                   y => 14,
                   x_root => 15,
                   y_root => 16,
                   state => [qw/shift-mask control-mask/],
                   is_hint => 2);

# FIXME: $event->axes not accessible currently

field_ok ($event, device => $device);
field_ok ($event, device => undef);

is ($event->get_time, 42, '$event->get_time');
# FIXME: special case for get_time()
# is (Gtk3::Gdk::Event::get_time (undef), 0,
#     "get_time with no event gets GDK_CURRENT_TIME, which is 0");

is ($event->get_state, [qw/shift-mask control-mask/], '$event->get_state');

is_deeply ([$event->get_coords], [13, 14], '$event->get_coords');

is_deeply ([$event->get_root_coords], [15, 16], '$event->get_root_coords');

is ($event->get_axis ("x"), 13);

$event = Gtk3::Gdk::Event->new ('motion-notify');
$event->device ($device);
$event->window ($window);
$event->request_motions;

# Button #######################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('button-press'),
	'Gtk3::Gdk::EventButton', 'Gtk3::Gdk::Event->new button');

fields_ok ($event, time => 42,
                   x => 13,
                   y => 14,
                   x_root => 15,
                   y_root => 16,
                   state => [qw/shift-mask control-mask/],
                   button => 2);

# FIXME: $event->axes not accessible currently

field_ok ($event, device => $device);
field_ok ($event, device => undef);

SKIP: {
  skip 'new 3.2 stuff', 2
    unless Gtk3::CHECK_VERSION(3, 2, 0);

  is ($event->get_button, 2);
  is ($event->get_click_count, 1);
}

# Scroll #######################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('scroll'),
	'Gtk3::Gdk::EventScroll', 'Gtk3::Gdk::Event->new scroll');

fields_ok ($event, time => 42,
                   x => 13,
                   y => 14,
                   x_root => 15,
                   y_root => 16,
                   delta_x => 17,
                   delta_y => 18,
                   state => [qw/shift-mask control-mask/],
                   direction => 'down');

field_ok ($event, device => $device);
field_ok ($event, device => undef);

SKIP: {
  skip 'new 3.2 stuff', 2
    unless Gtk3::CHECK_VERSION(3, 2, 0);
  is ($event->get_scroll_direction, 'down');

  #  <https://bugzilla.gnome.org/show_bug.cgi?id=677774>
  skip 'missing annotations', 1
    unless Gtk3::CHECK_VERSION(3, 5, 6);
  $event->direction ('smooth');
  is_deeply ([$event->get_scroll_deltas], [17, 18]);
}

# Key ##########################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('key-press'),
	'Gtk3::Gdk::EventKey', 'Gtk3::Gdk::Event->new key');

fields_ok ($event, time => 42,
                   state => [qw/shift-mask control-mask/],
                   keyval => 44,
                   hardware_keycode => 10,
                   group => 11,
                   is_modifier => Glib::TRUE);

SKIP: {
  skip 'new 3.2 stuff', 2
    unless Gtk3::CHECK_VERSION(3, 2, 0);

  is ($event->get_keycode, 10);
  is ($event->get_keyval, 44);
}

# Crossing #####################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('enter-notify'),
	'Gtk3::Gdk::EventCrossing', 'Gtk3::Gdk::Event->new crossing');

fields_ok ($event, time => 42,
                   x => 13,
                   y => 14,
                   x_root => 15,
                   y_root => 16,
                   mode => 'grab',
                   detail => 'nonlinear',
                   focus => Glib::TRUE,
                   state => [qw/shift-mask control-mask/]);

field_ok ($event, subwindow => $window);
field_ok ($event, subwindow => undef);

# Focus ########################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('focus-change'),
	'Gtk3::Gdk::EventFocus', 'Gtk3::Gdk::Event->new focus');

fields_ok ($event, in => 10);

# Configure ####################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('configure'),
	'Gtk3::Gdk::EventConfigure', 'Gtk3::Gdk::Event->new configure');

fields_ok ($event, x => 13,
                   y => 14,
                   width => 10,
                   height => 10);

# Property #####################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('property-notify'),
	'Gtk3::Gdk::EventProperty', 'Gtk3::Gdk::Event->new property');

fields_ok ($event, time => 42);

my $atom = Gtk3::Gdk::Atom::intern ('foo', Glib::FALSE);
$event->atom ($atom);
isa_ok ($event->atom, 'Gtk3::Gdk::Atom', '$property_event->atom');
is ($event->atom->name, $atom->name, '$property_event->atom');
$event->atom (undef);
is ($event->atom, undef);

SKIP: {
  # <https://bugzilla.gnome.org/show_bug.cgi?id=677775>
  skip 'missing annotations', 1
    unless Gtk3::CHECK_VERSION (3, 5, 6);
  field_ok ($event, state => 'new-value');
}

# Proximity ####################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('proximity-in'),
	'Gtk3::Gdk::EventProximity', 'Gtk3::Gdk::Event->new proximity');

fields_ok ($event, time => 42);

field_ok ($event, device => $device);
field_ok ($event, device => undef);

# Setting ######################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('setting'),
	'Gtk3::Gdk::EventSetting', 'Gtk3::Gdk::Event->new setting');

fields_ok ($event, action => 'new');

# FIXME: $event->name not accessible currently

# WindowState ##################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('window-state'),
	'Gtk3::Gdk::EventWindowState', 'Gtk3::Gdk::Event->new windowstate');

fields_ok ($event, changed_mask => [qw/withdrawn above/],
                   new_window_state => [qw/maximized sticky/]);

# DND ##########################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('drag-enter'),
	'Gtk3::Gdk::EventDND', 'Gtk3::Gdk::Event->new dnd');

fields_ok ($event, time => 42,
                   x_root => 15,
                   y_root => 16);

my $drag_context = Gtk3::Gdk::DragContext->new;
field_ok ($event, context => $drag_context);
field_ok ($event, context => undef);

# Selection ####################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ('selection-clear'),
	'Gtk3::Gdk::EventSelection', 'Gtk3::Gdk::Event->new selection');

fields_ok ($event, time => 42);

$event->property ($atom);
is ($event->property->name, $atom->name);
$event->selection ($atom);
is ($event->selection->name, $atom->name);
$event->target ($atom);
is ($event->target->name, $atom->name);

field_ok ($event, requestor => $window);
field_ok ($event, requestor => undef);

# OwnerChange ##################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ("owner-change"),
	"Gtk3::Gdk::EventOwnerChange");

fields_ok ($event, reason => 'destroy',
                   time => 42,
                   selection_time => 42);

field_ok ($event, owner => $window);
field_ok ($event, owner => undef);

$event->selection ($atom);
is ($event->selection->name, $atom->name);

# GrabBroken ##################################################################

isa_ok ($event = Gtk3::Gdk::Event->new ("grab-broken"),
	"Gtk3::Gdk::EventGrabBroken");

fields_ok ($event, keyboard => Glib::TRUE,
                   implicit => Glib::FALSE);

field_ok ($event, grab_window => $window);
field_ok ($event, grab_window => undef);

# Touch #######################################################################

SKIP: {
  skip 'new 3.4 stuff', 2
    unless Gtk3::CHECK_VERSION(3, 4, 0);

  isa_ok ($event = Gtk3::Gdk::Event->new ("touch-begin"),
          "Gtk3::Gdk::EventTouch");

  fields_ok ($event, time => 42,
                     x => 13, y => 14,
                     x_root => 15, y_root => 16,
                     state => [qw/shift-mask control-mask/],
                     emulating_pointer => Glib::TRUE);

  field_ok ($event, device => $device);
  field_ok ($event, device => undef);

  # FIXME: $event->axes not usable currently

  # FIXME: $event->sequence and get_event_sequence not usable currently
}

# Misc. #######################################################################

{
  my $event = Gtk3::Gdk::Event->new ('button-press');

  $event->put;
  ok (Gtk3::Gdk::events_pending);
  isa_ok (Gtk3::Gdk::Event::get, 'Gtk3::Gdk::EventButton');

  my $i_know_you = 0;
  Gtk3::Gdk::Event::handler_set (sub {
    return if $i_know_you++;
    my ($cb_event, $data) = @_;
    isa_ok ($cb_event, 'Gtk3::Gdk::EventButton');
    # pass to gtk+ default handler
    Gtk3::main_do_event ($cb_event);
  });

  $event->put;
  Gtk3::main_iteration while Gtk3::events_pending;

  # reset
  Gtk3::Gdk::Event::handler_set (undef);

  Gtk3::Gdk::set_show_events (Glib::FALSE);
  ok (!Gtk3::Gdk::get_show_events);
}

# Test that our custom event handling does not break callback marshalling due
# to incorrect handling of the perl stack.
{
  my $widget = Gtk3::Label->new ('Test');
  $widget->signal_connect (key_press_event => sub {
    my ($cb_widget, $cb_event) = @_;
    is ($cb_widget, $widget);
    isa_ok ($cb_event, 'Gtk3::Gdk::EventKey');
    is ($cb_event->keyval, 44);
    Glib::TRUE;
  });
  my $event = Gtk3::Gdk::Event->new ('key-press');
  $event->keyval (44);
  $widget->signal_emit (key_press_event => $event);
}

SKIP: {
  skip 'new 3.4 stuff', 1
    unless Gtk3::CHECK_VERSION (3, 4, 0);
  my $event = Gtk3::Gdk::Event->new ('button-press');
  $event->button (Gtk3::Gdk::BUTTON_SECONDARY);
  $event->window ($window);
  ok ($event->triggers_context_menu);
}

# FIXME: gdk_events_get_angle, gdk_events_get_center, gdk_events_get_distance
# are misbound
# {
#   my $event1 = Gtk3::Gdk::Event->new ('button-press');
#   $event1->x (1); $event1->y (0);
#   my $event2 = Gtk3::Gdk::Event->new ('button-press');
#   $event2->x (0); $event2->y (1);
#   warn join ', ', $event1->_get_angle ($event2);
#   warn join ', ', $event1->_get_center ($event2);
#   warn join ', ', $event1->_get_distance ($event2);
# }

__END__

Copyright (C) 2003-2012 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.

