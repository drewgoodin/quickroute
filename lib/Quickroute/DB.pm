package Quickroute::DB;

use DBI;

sub new {
  my ($class, $q) = @_;
  my $dbfile = $q->env->{'csv.db'};
  return bless {
    conn => DBI->connect("dbi:CSV:f_dir=$dbfile"),
  } => $class;
}

sub conn { shift->{conn} }

1;
