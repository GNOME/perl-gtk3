use Test::More;
use Gtk3;

if (!Gtk3::init_check ()) {
  plan skip_all => 'Gtk3::init_check failed';
}

sub check_gi_version {
  my ($x, $y, $z) = @_;
  return !system ('pkg-config', "--atleast-version=$x.$y.$z", 'gobject-introspection-1.0');
}

1;
