package main;
use Quickroute;

our (%routes, $status, %headers);

do './routes.pl';        #populates route hash

my $app = sub {

  our $env = shift;

  my $method = $env->{REQUEST_METHOD};
  my $path   = $env->{PATH_INFO} // '/';
  my $action = $routes{$path}->{$method} // $routes{error};

  #possibly overwritten after route is run
  $status = 200;
  %headers = ('Content-type' => 'text/html');

  my $content = $action->(); #run the route

  [ 
    $status,
  [ %headers ],           #psgi response
  [ $content ],
  ]

};
