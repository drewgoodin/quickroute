noroute sub {
  $r->status(404);
  template('error')
};

route '/', get => sub {
  template('index')
};

route '/style.css', get => sub {
  $r->type('css'); 
  template('style')
};
