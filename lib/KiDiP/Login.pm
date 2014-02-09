package KiDiP::Login;
use Mojo::Base 'Mojolicious::Controller';

use Database::Mongo;
use Data::Dumper;

# This action will render a template
sub login {
    my $self = shift;
    
    my $log = $self->app->log;
    if($self->req->method eq "POST") {
        my $username = $self->param('username');
        my $password = $self->param('password');
        $log->info("Check auhtentication for user ".$username);
        
        if($self->authenticate($username, $password)) {
            $self->redirect_to('/');
        }
        else {
            $self->redirect_to('/failed');
        }
  }
    

}

sub failed {
    my $self = shift;
    $self->logout(); 
    $self->render(text => 'Faild to authenticate');
}

1;
