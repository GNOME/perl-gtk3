#!/usr/bin/perl
#
# Originally copied from Gtk2/t/GtkRecentChooserDialog.t
#

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;

plan tests => 12;

my $window = Gtk3::Window->new;
my $manager = Gtk3::RecentManager->new;

my $chooser = Gtk3::RecentChooserDialog->new ('Test', $window);
isa_ok ($chooser, 'Gtk3::RecentChooser');
isa_ok ($chooser, 'Gtk3::RecentChooserDialog');

$chooser = Gtk3::RecentChooserDialog->new ('Test', undef);
isa_ok ($chooser, 'Gtk3::RecentChooser');
isa_ok ($chooser, 'Gtk3::RecentChooserDialog');

$chooser = Gtk3::RecentChooserDialog->new_for_manager ('Test', $window, $manager);
isa_ok ($chooser, 'Gtk3::RecentChooser');
isa_ok ($chooser, 'Gtk3::RecentChooserDialog');

$chooser = Gtk3::RecentChooserDialog->new_for_manager ('Test', undef, $manager);
isa_ok ($chooser, 'Gtk3::RecentChooser');
isa_ok ($chooser, 'Gtk3::RecentChooserDialog');

$chooser = Gtk3::RecentChooserDialog->new ('Test', $window, 'gtk-ok' => 'ok');
isa_ok ($chooser, 'Gtk3::RecentChooser');
isa_ok ($chooser, 'Gtk3::RecentChooserDialog');

$chooser = Gtk3::RecentChooserDialog->new_for_manager ('Test', $window, $manager, 'gtk-ok' => 'ok', 'gtk-cancel' => 'cancel');
isa_ok ($chooser, 'Gtk3::RecentChooser');
isa_ok ($chooser, 'Gtk3::RecentChooserDialog');

__END__

Copyright (C) 2003-2012 by the gtk2-perl team (see the file AUTHORS for the
full list).  See LICENSE for more information.
