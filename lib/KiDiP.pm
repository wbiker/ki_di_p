package KiDiP;
use Mojo::Base 'Mojolicious';

use Database::Mongo;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to(controller => 'employee', action => 'welcome');
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


  $self->{mongo} = Database::Mongo->new(database => 'kidip', collections => [qw/employee work_hour workshift_duration/]);
}

1;
