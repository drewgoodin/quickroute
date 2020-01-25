noroute sub {
  $q->status(404);
  template('error')
};

route '/', get => sub {
  $q->is_auth ?
    template('welcome') :
    template('login')
};

route '/', post => sub {
  $q->authen;
  $q->status(303);
  $q->set_header(Location => '/');
  return '';
};

route '/logout', get => sub { 
  $q->logout;
  $q->status(303);
  $q->set_header('Location' => '/');
  return '';
};

route '/auth', get => sub {
  unless ($q->is_auth) {
    $q->status(403);
    return template('forbid');
  }
  template('autharea')
};
