route '/', get => sub {
  template('auth');
};

noroute sub {
  $q->status(404);
  template('error')
};
