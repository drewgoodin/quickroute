noroute sub {
  status(404);
  type('text');
  template('error')
};

route '/', get => sub {
  status(200);
  type('html'); 
  template('index')
};

