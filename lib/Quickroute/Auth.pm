package Quickroute::Auth;

use Authen::Simple::DBI;
use Crypt::Eksblowfish::Bcrypt qw!bcrypt_hash!;
use DateTime;
use Plack::Request;
use Quickroute::DB;
use Quickroute::Session;
use URL::Encode qw!url_params_mixed!;

sub expire {
  my $q = shift;
  $q->env->{'psgix.session.options'}->{expires} = undef; #strip expire time from sent cookie
}

sub timestamp {
  my $q = shift;
  $q->env->{'psgix.session'}->{last_access} = DateTime->now()->epoch();
}

sub is_auth {
  my $q = shift;
  my $auth_status = $q->env->{'psgix.session'}->{auth};
  if ($auth_status) {
    expire($q) unless $q->env->{'psgix.session'}->{persist};
    timestamp($q);
    return 1;
  }
  return 0;
}

sub authen { 
  my $q = shift;
  my $content = Plack::Request->new($q->env)->content;
  my $body = url_params_mixed($content);
  my $username = $body->{username};

  my $dbh = Quickroute::DB->new($q);
  my $sth = $dbh->conn->prepare('select salt, privilege from users where username = ?');
  $sth->execute($username);
  my @passarr = $sth->fetchrow_array();

  my $salt = (shift @passarr) // return 0;
  my $settings = { 
    key_nul => 1,
    cost   => 6,
    salt   => $salt,
  };
  my $password = bcrypt_hash($settings, $body->{password});

  my $csv_db = $q->env->{'csv.db'};
  my $authdb = Authen::Simple::DBI->new(
    dsn       => "dbi:CSV:f_dir=$csv_db",
    statement => 'select password from users where username = ?'
  );

  if ( $authdb->authenticate( $username, $password ) ) {
    $q->env->{'psgix.session'}->{auth} = 1;
    $q->env->{'psgix.session'}->{priv} = shift @passarr;
    $q->env->{'psgix.session'}->{user} = $username;
    $q->env->{'psgix.session'}->{created} = DateTime->now()->epoch();
    $q->env->{'psgix.session'}->{persist} = 1 if $body->{remember};
    $q->env->{'psgix.session.options'}->{change_id} = 1;
    return 1;
  }

  return 0;
}

sub auth_session {
  my ($env, $root) = @_;
  my $id = $env->{HTTP_COOKIE};
  return 0 unless $id;
  $id =~ s/plack_session=(.*)/$1/;
  my $session = Quickroute::Session::cache($root);
  my $data = $session->cache->get($id);
  my $auth = $data->{auth};
  return 0 unless $auth;
}

1;

sub logout {
  my $q = shift;
  $q->env->{'psgix.session.options'}->{expire} = 1;
}

1;
