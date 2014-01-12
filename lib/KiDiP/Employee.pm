package KiDiP::Employee;
use Mojo::Base 'Mojolicious::Controller';

use Database::Mongo;
use Data::Dumper;
my $mongo = Database::Mongo->new(database => 'kidip', collections => [qw/employee work_hour workshift_duration/]);

# This action will render a template
sub list {
  my $self = shift;
    
  my $log = $self->app->log;
  $log->info("list action called");
  my $employees = $mongo->find('employee', {});
  # Render template "employee/list.html.ep" with message
  $self->stash(employees => $employees);
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}

sub employee {
    my $self = shift;
    my $employee_id = $self->param('emloyee_id');
    
    my $employee = $mongo->find('employee', {_id => $employee_id});
    $self->stash(employee => $employee);
}

1;
