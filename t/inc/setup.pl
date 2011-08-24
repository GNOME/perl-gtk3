use Test::More;
use Gtk3;

if (!Gtk3::init_check ()) {
  plan skip_all => 'Gtk3::init_check failed';
}

1;
