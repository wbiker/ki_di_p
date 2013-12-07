package KiDiP::Example;
use Mojo::Base 'Mojolicious::Controller';

use Database::Mongo;
my $mongo = Database::Mongo->new(database => 'kidip', collections => [qw/testruns/]);

# This action will render a template
sub welcome {
  my $self = shift;

  $mongo->insert('testruns', {date => time, name => "Wolf", status => 'work'});
  # Render template "example/welcome.html.ep" with message
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}

1;
