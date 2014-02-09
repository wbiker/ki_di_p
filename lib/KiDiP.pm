package KiDiP;
use Mojo::Base 'Mojolicious';
use Mojolicious::Plugin::Authentication;

use Database::Mongo;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');
  $self->plugin('authentication' => {
	'autoload_user' => 1,
	'session_key' => 'kidip',
	'load_user' => \&load_user,
	'validate_user' => \&validate_user,
  });
  $self->sessions->default_expiration(3600);

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to(controller => 'employee', action => 'welcome');
  $r->get('/login')->to(controller => 'login', action => 'login');
  $r->get('/failed')->to(controller => 'login', action => 'failed');
  $r->post('/login')->to(controller => 'login', action => 'login');
  $r->get('/employee/new')->to(controller => 'employee', action => 'new_employee');
  $r->get('/employee/list')->to(controller => 'employee', action => 'list');
  $r->get('/employee/:employee_id')->to(controller => 'employee', action => 'edit_employee');
  $r->post('/employee/:employee_id/update')->to(controller => 'employee', action => 'update_employee');
  $r->get('/employee/:employee_id/delete')->to(controller => 'employee', action => 'delete_employee');
  $r->get('/planning')->to(controller => 'planning', action => 'planning');

  $r->post('/employee/new')->to(controller => 'employee', action => 'new_employee');
  $r->post('/employee/:employee_id')->to(controller => 'employee', action => 'edit_employee');

  $r->get('/workhour/list')->to(controller => 'workhour', action => 'list');
  $r->get('/workhour/new')->to(controller => 'workhour', action => 'new_workhour');
  $r->post('/workhour/new')->to(controller => 'workhour', action => 'new_workhour');

  $r->get('/getlocaldata')->to(controller => 'employee', action => 'getlocaldata');
  $r->post('/createpdf')->to(controller => 'employee', action => 'createpdf');

  

  $self->{mongo} = Database::Mongo->new(database => 'kidip', collections => [qw/employee work_hour workshift/]);
}

sub load_user {
    my $self = shift;
    my $uid = shift;
    return $uid;
} 

sub validate_user {
    my $self = shift;
    my $un = shift || '';
    my $pw = shift || '';
    my $extra = shift  || {};

    if('betty' eq $un && 'sophia240105' eq $pw) {
        return $un;
    }

    return undef;
}

1;
