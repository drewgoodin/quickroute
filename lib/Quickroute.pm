package Quickroute;

use strict;
use HTML::Mason;
use Exporter qw!import!;
our @EXPORT = qw!
  noroute
  route
  set_header
  status
  template
  type
  !;

my %routes;

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
  return bless { 
    env => $env,
    status => 200,
    headers => { 'Content-type' => 'text/html' },
  } => $class;
}

sub go {
  my $self = shift;
  my $path = $self->{env}->{PATH_INFO} // '/';
  my $method = $self->{env}->{REQUEST_METHOD};
  $path =~ s/\/\z// unless $path eq '/';
  my $action = $routes{$path}->{$method} // $routes{error};
  delete $routes{$path} if $action == $routes{error};
  my $content = $action->();
  [ $self->{status}, [ %{$self->{headers}} ], [ $content ] ]
}

sub set_header { 
  my $self = shift;
  my %pair = @_;
  $self->{headers}->{$_} = $pair{$_} for keys %pair;
}

sub status { 
  my ($self, $code) = @_;
  $self->{status} = $code;
}

sub type   { 
  my ($self, $type) = @_;
  $self->{headers}->{'Content-type'} = $mime{$type};
}

### Exports ###

sub noroute { $routes{error} = shift }

sub route {
  my ($path, $method, $action) = @_;
  $routes{$path}->{uc $method} = $action;
}

sub template {
  my ($component, @args) = @_;
  my $buf;
  $interp->out_method(\$buf);
  $interp->exec("/" . $component, @args);
  $buf;
}

1;
