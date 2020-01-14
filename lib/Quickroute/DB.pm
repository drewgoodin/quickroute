package Quickroute::DB;

use DBI;

sub new {
  my ($class, $q) = @_;
  my $dbfile = $q->env->{'sqlite.file'};
  return bless {
    conn => DBI->connect("dbi:SQLite:dbname=$dbfile","",""),
  } => $class;
}

sub conn { shift->{conn} }

1;
