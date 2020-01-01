use lib 'lib';
use Quickroute;
do './routes.pl';

my $app = sub { (our $r = Quickroute->new(shift))->go() }
