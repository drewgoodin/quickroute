use Quickroute::Auth;

route '/', get => sub {
  if (Quickroute::Auth::is_auth($q)) {
    return template('welcome');
  }
  else {
    return template('login');
  }
};

route '/', post => sub {
  Quickroute::Auth::authen($q);
  $q->status(303);
  $q->set_header(Location => '/');
  return '';
};

route '/logout', get => sub { 
  Quickroute::Auth::logout($q);
  $q->status(303);
  $q->set_header('Location' => '/');
  return '';
};

noroute sub {
  $q->status(404);
  template('error')
};
