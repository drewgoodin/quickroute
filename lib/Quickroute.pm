package Quickroute;

use Exporter qw!import!;
our @EXPORT = qw!
  noroute
  route
  set_header
  status
  template
  type
  !;

my (%routes, $status, %headers); # these are set by user via exported functions.

my $interp = HTML::Mason::Interp->new(comp_root => "$ENV{PWD}/templates");

my %mime = (
  plain => 'text/plain',
  html => 'text/html',
  css  => 'text/css',
  js   => 'text/javascript',
  json => 'application/json',
  xml  => 'text/xml',
);

sub new { 
  my ($class, $env) = @_;
  return bless { env => $env } => $class;
}

sub go {
  my $self = shift;
  my $path = $self->{env}->{PATH_INFO} // '/';
  my $method = $self->{env}->{REQUEST_METHOD};
  my $action = $routes{$path}->{$method} // $routes{error};

  $status = 200;                              # default, might change when route is run
  %headers = ('Content-type' => 'text/html'); # likewise

  my $content = $action->();                  # run the route
  [ $status, [ %headers ], [ $content ] ]
}

### Exports ###

sub noroute { $routes{error} = shift }

sub route {
  my ($path, $method, $action) = @_;
  $routes{$path}->{uc $method} = $action;
}

sub set_header { 
  my %pair = @_;
  $headers{$_} = $pair{$_} for keys %pair;
}

sub status { $status = shift }

sub template {
  my ($component, @args) = @_;
  my $buf;
  $interp->out_method(\$buf);
  $interp->exec("/" . $component, @args);
  $buf;
}

sub type   { $headers{'Content-type'} = shift }

1;
