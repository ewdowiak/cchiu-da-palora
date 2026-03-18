package Dizziunariu;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;

  # Normal GET routes to controllers
  $r->get('/')->to('main#welcome');
  $r->get('/dieli/')->to('dieli#welcome');
  $r->get('/chiu/')->to('chiu#welcome');
  $r->get('/trova/')->to('trova#welcome');
  $r->get('/traina/')->to('traina#welcome');

  # Normal POST routes to controllers
  $r->post('/')->to('main#welcome');
  $r->post('/dieli/')->to('dieli#welcome');
  $r->post('/chiu/')->to('chiu#welcome');
  $r->post('/trova/')->to('trova#welcome');
  $r->post('/traina/')->to('traina#welcome');
}

1;
