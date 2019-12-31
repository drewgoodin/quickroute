noroute sub {
  status(404);
  template('error')
};

route '/', get => sub {
  template('index')
};

route '/style.css', get => sub {
  type('css'); 
  template('style')
};
