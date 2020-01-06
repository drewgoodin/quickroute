use lib 'lib';
use Quickroute;
do './routes.pl';

my $app = sub { (our $q = Quickroute->new(shift, %Quickroute::routes))->go() }
