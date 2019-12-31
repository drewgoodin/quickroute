use Quickroute;
do './routes.pl';

my $app = sub { Quickroute->new(shift)->go() }
