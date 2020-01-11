package Quickroute::Session;

use CHI;
use Plack::Session::Store::Cache;
use Plack::Session::State::Cookie;

sub cache {
  my ($root, $expires) = @_;
  my $cache;
  $cache = $expires ?
    CHI->new(
      driver => 'File',
      root_dir => $root,
      expires_in => $expires,
    )               : 
    CHI->new(
      driver => 'File',
      root_dir => $root,
    );
  return Plack::Session::Store::Cache->new(cache => $cache);
}

sub cookie {
  my ($secure, $expires) = @_;
  my $cookie = Plack::Session::State::Cookie->new(
    secure => $secure,
    httponly => 1,
    expires => $expires,
  );
}

1;
