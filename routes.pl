noroute sub {
  my $self = shift;
  $self->status(404);
  template('error')
};

route '/', get => sub {
  template('index')
};

route '/style.css', get => sub {
  my $self = shift;
  $self->type('css'); 
  template('style')
};
