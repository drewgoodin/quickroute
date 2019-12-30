noroute( sub {
  status(404);
  type('plain');
  template('error')
});

route '/', get => sub {
  status(200);
  type('html'); 
  template('index')
};

route '/api', get => sub {
  my %hsh = (hi => 'world');
  status(201);
  type('json');
  require JSON;
  my $json = JSON->new();
  $json->encode(\%hsh)
};


