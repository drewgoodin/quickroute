noroute sub {
  $q->status(404);
  template('error')
};

route '/', get => sub {
  template('index')
};

route '/style.css', get => sub {
  $q->type('css'); 
  template('style')
};
