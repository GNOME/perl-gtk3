#!/usr/bin/perl

BEGIN { require './t/inc/setup.pl' }

use strict;
use warnings;
use Glib ':constants';

plan tests => 171;

{
  package CustomList;
  use strict;
  use warnings;
  use Glib qw(TRUE FALSE);
  use Test::More;

  use Glib::Object::Subclass
    Glib::Object::,
	interfaces => [ Gtk3::TreeModel::, Gtk3::TreeSortable:: ],
          ;

  # one-time init:
  my %ordmap;
  {
    my $i = 0;
    %ordmap = map { $_ => $i++ } qw(
                                     First Second Third Fourth Fifth
                                     Sixth Seventh Eighth Ninth Tenth
                                     Eleventh Twelfth Thirteenth Fourteenth Fifteenth
                                     Sixteenth Seventeenth Eighteenth Nineteenth Twentieth
                                 );
  }

  sub INIT_INSTANCE {
    my ($list) = @_;

    isa_ok ($list, "CustomList", "INIT_INSTANCE: list");

    $list->{data}  = [];

    foreach my $val (sort { $ordmap{$a} <=> $ordmap{$b} } keys %ordmap) {
      my $record = { pos => $ordmap{$val}, value => $val };
      push @{$list->{data}}, $record;
    }

    $list->{stamp} = 23;
    $list->{sort_column_id} = -1;
    $list->{sort_order} = "ascending";
  }

  sub FINALIZE_INSTANCE {
    my ($list) = @_;

    isa_ok ($list, "CustomList", "FINALIZE_INSTANCE: list");
  }

  sub GET_FLAGS {
    my ($list) = @_;

    isa_ok ($list, "CustomList", "GET_FLAGS: list");

    return [ qw/list-only iters-persist/ ];
  }

  sub GET_N_COLUMNS {
    my ($list) = @_;

    isa_ok ($list, "CustomList", "GET_N_COLUMNS: list");

    # we don't actually have 23 columns, just 1 -- but the point here is
    # to test that the marshaling actually puts through the correct
    # number, not just nonzero.
    return 23;
  }

  sub GET_COLUMN_TYPE {
    my ($list, $column) = @_;

    isa_ok ($list, "CustomList", "GET_COLUMN_TYPE: list");
    is ($column, 1, "GET_COLUMN_TYPE: column correct");

    return Glib::String::
  }

  sub GET_ITER {
    my ($list, $path) = @_;

    isa_ok ($list, "CustomList", "GET_ITER: list");
    isa_ok ($path, "Gtk3::TreePath", "GET_ITER: path");

    my @indices = $path->get_indices;
    my $depth   = $path->get_depth;

    ok ($depth == 1, "GET_ITER: depth OK");

    my $n = $indices[0];

    ok ($n < @{$list->{data}}, "GET_ITER: first path index OK");
    ok ($n > 0, "GET_ITER: first path index OK");

    my $record = $list->{data}[$n];

    ok (defined ($record), "GET_ITER: record defined");
    ok ($record->{pos} == $n, "GET_ITER: record has the correct index");

    return (TRUE, Gtk3::TreeIter->new (stamp => $list->{stamp}, user_data => $record));
  }

  sub GET_PATH {
    my ($list, $iter) = @_;

    isa_ok ($list, "CustomList", "GET_PATH: list");
    ok ($iter->stamp == $list->{stamp}, "GET_PATH: stamps agree");

    my $record = $iter->user_data;

    my $path = Gtk3::TreePath->new;
    $path->append_index ($record->{pos});

    return $path;
  }

  sub GET_VALUE {
    my ($list, $iter, $column) = @_;

    isa_ok ($list, "CustomList");
    ok ($iter->stamp == $list->{stamp}, "GET_VALUE: stamps agree");

    is ($column, 1, "GET_VALUE: column correct");

    my $record = $iter->user_data;

    ok (defined ($record), "GET_VALUE: record defined");

    ok ($record->{pos} < @{$list->{data}}, "GET_VALUE: record within bounds");

    return Glib::Object::Introspection::GValueWrapper->new (
      Glib::String::, $record->{value});
  }

  sub ITER_NEXT {
    my ($list, $iter) = @_;

    isa_ok ($list, "CustomList", "ITER_NEXT: list");
    ok ($iter->stamp == $list->{stamp}, "ITER_NEXT: stamps agree");

    my $record = $iter->user_data;
    ok (defined ($record), "ITER_NEXT: record defined");

    # Is this the last record in the list?
    return FALSE if $record->{pos} >= @{ $list->{data} };

    my $nextrecord = $list->{data}[$record->{pos} + 1];
    ok (defined ($nextrecord), "ITER_NEXT: next record defined");

    ok ($nextrecord->{pos} == ($record->{pos} + 1), "ITER_NEXT: next record's pos OK");

    $iter->user_data ($nextrecord);
    return TRUE;
  }

  sub ITER_CHILDREN {
    my ($list, $iter) = @_;

    isa_ok ($list, "CustomList", "ITER_CHILDREN: list");

    # this is a list, nodes have no children
    return (FALSE, undef) if $iter;

    # parent == NULL is a special case; we need to return the first top-level row

    # No rows => no first row
    return (FALSE, undef) unless @{ $list->{data} };

    # Set iter to first item in list
    return (TRUE, Gtk3::TreeIter->new (stamp => $list->{stamp}, user_data => $list->{data}[0]));
  }

  sub ITER_HAS_CHILD {
    my ($list, $iter) = @_;

    isa_ok ($list, "CustomList", "ITER_HAS_CHILD: list");
    ok ($iter->stamp == $list->{stamp}, "ITER_HAS_CHILD: stamps agree");

    return 'asdf';
  }

  sub ITER_N_CHILDREN {
    my ($list, $iter) = @_;

    isa_ok ($list, "CustomList", "ITER_N_CHILDREN: list");

    # special case: if iter == NULL, return number of top-level rows
    return scalar @{$list->{data}} if ! $iter;

    return 0;                   # otherwise, this is easy again for a list
  }

  sub ITER_NTH_CHILD {
    my ($list, $iter, $n) = @_;

    isa_ok ($list, "CustomList", "ITER_NTH_CHILD: list");

    # a list has only top-level rows
    return (FALSE, undef) if $iter;

    # special case: if parent == NULL, set iter to n-th top-level row

    ok ($n < @{$list->{data}}, "ITER_NTH_CHILD: n bounded correctly");

    my $record = $list->{data}[$n];

    ok (defined ($record), "ITER_NTH_CHILD: record defined");
    ok ($record->{pos} == $n, "ITER_NTH_CHILD: record's pos correct");

    return (TRUE, Gtk3::TreeIter->new (stamp => $list->{stamp}, user_data => $record));
  }

  sub ITER_PARENT {
    my ($list, $iter) = @_;

    isa_ok ($list, "CustomList", "ITER_PARENT: list");

    return (FALSE, undef);
  }

  sub REF_NODE {
    my ($list, $iter) = @_;

    isa_ok ($list, "CustomList", "REF_NODE: list");
    ok ($iter->stamp == $list->{stamp}, "REF_NODE: stamps agree");
  }

  sub UNREF_NODE {
    my ($list, $iter) = @_;

    isa_ok ($list, "CustomList", "UNREF_NODE: list");
    ok ($iter->stamp == $list->{stamp}, "UNREF_NODE: stamps agree");
  }

  sub set {
    my $list = shift;
    my $iter = shift;

    isa_ok ($list, "CustomList", "set: list");
    isa_ok ($iter, "Gtk3::TreeIter", "set: iter");

    my ($col, $value) = @_;
    ok ($col == 1, "set: col OK");

    my $record = $iter->user_data;

    $record->{value} = $value;
  }

  sub get_iter_from_ordinal {
    my $list = shift;
    my $ord  = shift;

    isa_ok ($list, "CustomList", "get_iter_from_ordinal: list");

    my $n = $ordmap{$ord};

    my $record = $list->{data}[$n];

    ok (defined ($record), "get_iter_from_ordinal: record is valid");

    my $iter = Gtk3::TreeIter->new (stamp => $list->{stamp}, user_data => $record);

    isa_ok ($iter, "Gtk3::TreeIter", "get_iter_from_ordinal: iter");

    return $iter;
  }

  ###############################################################################

  sub GET_SORT_COLUMN_ID {
    my ($list) = @_;

    isa_ok ($list, "CustomList", "GET_SORT_COLUMN_ID: list");

    my $id = $list->{sort_column_id};
    my $order = $list->{sort_order};

    return $id >= 0, $id, $order;
  }

  sub SET_SORT_COLUMN_ID {
    my ($list, $id, $order) = @_;

    isa_ok ($list, "CustomList", "SET_SORT_COLUMN_ID: list");
    is ($id, 3, "SET_SORT_COLUMN_ID: id OK");
    is ($order, "descending", "SET_SORT_COLUMN_ID: order OK");

    $list->{sort_column_id} = $id;
    $list->{sort_order} = $order;
  }

  sub SET_SORT_FUNC {
    my ($list, $id, $func, $data) = @_;

    isa_ok ($list, "CustomList", "SET_SORT_FUNC: list");
    ok ($id == 2 || $id == 3, "SET_SORT_FUNC: id OK");
    ok (defined $func, "SET_SORT_FUNC: func OK");
    ok (defined $data, "SET_SORT_FUNC: data OK");

    $list->{sort_funcs}->[$id] = [$func, $data];
  }

  sub SET_DEFAULT_SORT_FUNC {
    my ($list, $func, $data) = @_;

    isa_ok ($list, "CustomList", "SET_DEFAULT_SORT_FUNC: list");
    ok (defined $func, "SET_SORT_FUNC: func OK");
    ok (defined $data, "SET_DEFAULT_SORT_FUNC: data OK");

    $list->{sort_func_default} = [$func, $data];
  }

  sub HAS_DEFAULT_SORT_FUNC {
    my ($list) = @_;

    isa_ok ($list, "CustomList", "HAS_DEFAULT_SORT_FUNC: list");

    return defined $list->{sort_func_default};
  }

  sub sort {
    my ($list, $id) = @_;
    my $a = $list->get_iter_from_string (1);
    my $b = $list->get_iter_from_string (2);

    if (exists $list->{sort_funcs}->[$id]) {
      my $func = $list->{sort_funcs}->[$id]->[0];
      my $data = $list->{sort_funcs}->[$id]->[1];

      is ($func->($list, $a, $b, $data), -1);
    } else {
      my $func = $list->{sort_func_default}->[0];
      my $data = $list->{sort_func_default}->[1];

      is ($func->($list, $a, $b, $data), 1);
    }
  }
}

{
  my $model = CustomList->new;

  ok ($model->get_flags eq [qw/iters-persist list-only/]);
  is ($model->get_n_columns, 23, "get_n_columns reports the number correctly");
  is ($model->get_column_type (1), Glib::String::);

  my $path = Gtk3::TreePath->new ("5");
  my $iter;

  isa_ok ($iter = $model->get_iter ($path), "Gtk3::TreeIter");
  isa_ok ($path = $model->get_path ($iter), "Gtk3::TreePath");
  is_deeply ([$path->get_indices], [5]);

  is ($model->get_value ($iter, 1), "Sixth");
  is ($model->get ($iter, 1), "Sixth");

  $model->iter_next ($iter);
  isa_ok ($path = $model->get_path ($iter), "Gtk3::TreePath");
  is_deeply ([$path->get_indices], [6]);

  isa_ok ($iter = $model->iter_children(undef), "Gtk3::TreeIter");
  isa_ok ($path = $model->get_path ($iter), "Gtk3::TreePath");
  is_deeply ([$path->get_indices], [0]);

  is ($model->iter_has_child ($iter), TRUE);
  is ($model->iter_n_children ($iter), 0);

  isa_ok ($iter = $model->iter_nth_child (undef, 7), "Gtk3::TreeIter");
  isa_ok ($path = $model->get_path ($iter), "Gtk3::TreePath");
  is_deeply ([$path->get_indices], [7]);

  ok (not defined ($model->iter_parent ($iter)));

  isa_ok ($iter = $model->get_iter_from_ordinal ('Twelfth'), "Gtk3::TreeIter");
  isa_ok ($path = $model->get_path ($iter), "Gtk3::TreePath");
  is_deeply ([$path->get_indices], [11]);

  $model->set($iter, 1, '12th');
  is ($model->get($iter, 1), '12th');

  $model->ref_node ($iter);
  $model->unref_node ($iter);

  SKIP: {
    skip 'rows_reordered is not usable currently', 8;
    my $signal_finished = 0;
    my $len = @{$model->{data}};
    my @array = (0 .. $len-1);
    my $id = $model->signal_connect (rows_reordered => sub {
                                       my ($s_model, $path, $iter, $aref) = @_;
                                       is ($s_model, $model);
                                       isa_ok ($path, "Gtk3::TreePath");
                                       my @indices = $path->get_indices;
                                       is_deeply (\@indices, []);
                                       is ($iter, undef);
                                       is_deeply ($aref, \@array);
                                       $signal_finished = 1;
                                     });
    $model->rows_reordered (Gtk3::TreePath->new, undef, @array);
    ok ($signal_finished, 'rows-reordered signal ran');
    $model->signal_handler_disconnect ($id);
  }

  my $sorter_two = sub {
    my ($list, $a, $b, $data) = @_;

    isa_ok ($list, "CustomList");
    isa_ok ($a, "Gtk3::TreeIter");
    isa_ok ($b, "Gtk3::TreeIter");
    is ($data, "tada");

    return -1;
  };

  my $sorter_three = sub {
    my ($list, $a, $b, $data) = @_;

    isa_ok ($list, "CustomList");
    isa_ok ($a, "Gtk3::TreeIter");
    isa_ok ($b, "Gtk3::TreeIter");
    is ($data, "data");

    return -1;
  };

  my $default_sorter = sub {
    my ($list, $a, $b, $data) = @_;

    isa_ok ($list, "CustomList");
    isa_ok ($a, "Gtk3::TreeIter");
    isa_ok ($b, "Gtk3::TreeIter");
    is ($data, "atad");

    return 1;
  };

  $model->set_sort_column_id (3, "descending");
  is_deeply ([$model->get_sort_column_id], [TRUE, 3, "descending"]);

  $model->set_sort_func (2, $sorter_two, "tada");
  $model->set_sort_func (3, $sorter_three, "data");
  $model->set_default_sort_func ($default_sorter, "atad");
  ok ($model->has_default_sort_func);

  $model->sort(2);
  $model->sort(3);
  $model->sort(23);

  # This should result in a call to FINALIZE_INSTANCE
  $model = undef;
}

###############################################################################

{
  package StackTestModel;
  use strict;
  use warnings;
  use Glib qw/TRUE FALSE/;

  use Glib::Object::Subclass
    Glib::Object::,
        interfaces => [ Gtk3::TreeModel::, Gtk3::TreeSortable:: ];

  our @ROW = (100,200,300,400,500,600,700,800,900,1000);

  sub grow_the_stack { 1 .. 500; };

  sub GET_N_COLUMNS {
    my @list = grow_the_stack();
    return scalar @ROW;
  }

  sub GET_COLUMN_TYPE { return 'Glib::String'; }

  sub GET_ITER { return (TRUE, Gtk3::TreeIter->new (stamp => 123)); }

  sub GET_VALUE {
    my ($self, $iter, $col) = @_;
    my @list = grow_the_stack();
    return Glib::Object::Introspection::GValueWrapper->new (
      'Glib::String', $ROW[$col]);
  }

  sub GET_SORT_COLUMN_ID {
    my @list = grow_the_stack();
    return TRUE, 3, 'ascending';
  }
}

{
  my $model = StackTestModel->new;
  is_deeply ([ $model->get ($model->get_iter_first) ],
             [ @StackTestModel::ROW ],
             '$model->get ($iter) does not result in stack corruption');

  is_deeply ([ $model->get ($model->get_iter_first, reverse 0 .. 9) ],
             [ reverse @StackTestModel::ROW ],
             '$model->get ($iter, @columns) does not result in stack corruption');

  is_deeply ([ $model->get_sort_column_id ],
             [ TRUE, 3, 'ascending' ],
             '$model->get_sort_column_id does not result in stack corruption');
}
