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

noroute sub {
  $q->status(404);
  template('error')
};
