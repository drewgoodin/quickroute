package Quickroute;
use Exporter qw!import!;

our @EXPORT = qw!
  route
  noroute
  status
  type
  set_header
  template
  !;

my $interp = HTML::Mason::Interp->new(comp_root => "$ENV{PWD}/templates");

my %mime = (
  plain => 'text/plain',
  html => 'text/html',
  css  => 'text/css',
  js   => 'text/javascript',
  json => 'application/json',
  xml  => 'text/xml',
);

sub route {
  my ($path, $method, $sub) = @_;
  $method = uc $method;
  $main::routes{$path}->{$method} = $sub;
}

sub noroute { $main::routes{error} = shift }

sub status  { $main::status = shift }

sub type { 
  my $type = shift; 
  @main::headers{'Content-type'} = $mime{$type};
}

sub set_header { 
  my %pair = @_;
  $main::headers{$_} = $pair{$_} for keys %pair;
}

sub template {
  my ($component, @args) = @_;
  my $buf;
  $interp->out_method(\$buf);
  $interp->exec("/" . $component, @args);
  $buf;
}

1;
