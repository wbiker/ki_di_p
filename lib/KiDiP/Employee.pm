package KiDiP::Employee;
use Mojo::Base 'Mojolicious::Controller';

use Database::Mongo;
use Data::Dumper;

# This action will render a template
sub list {
  my $self = shift;
    
  my $log = $self->app->log;
  my $mongo = $self->app->{mongo};
  $log->info("list action called");
  my $employees = $mongo->find('employee', {});
  # Render template "employee/list.html.ep" with message
  $self->stash(employees => $employees);
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}

sub edit_employee {
    my $self = shift;
    my $employee_id = $self->param('employee_id');
    $self->app->log->debug("employee ID: $employee_id"); 

    my $mongo = $self->app->{mongo};
    if('GET' eq $self->req->method) {
        my $employee = $mongo->find_one('employee', $employee_id);
        my $work_shifts_cursor = $mongo->find('work_hour', {});
        my $work_shifts = [];
        while(my $wh = $work_shifts_cursor->next) {
           push($work_shifts, $wh);
        }
        $self->stash(employee => $employee);
        $self->stash(workshifts => $work_shifts);
        return $self->render;
    }

    my $empl = {};
    $empl->{lastname} = $self->param('lastname');
    $empl->{firstname} = $self->param('firstname');
    $empl->{vacation} = $self->param('vacation');
    $empl->{total_work_time} = $self->param('total_work_time');
    $empl->{work_start} = $self->param('work_start');
    $empl->{work_shift} = $self->param('work_shift');

    $mongo->update('employee', $employee_id, $empl);
    $self->redirect_to('/employee/list');
}

# is triggered by URL/employee/new
sub new_employee {
    my $self = shift;

    my $log = $self->app->log;

    if('GET' eq $self->req->method) {
        my $wh_cursor = $self->app->{mongo}->find('work_hour');
        my $workhours = [];
        while(my $workh = $wh_cursor->next) {
            push($workhours, {name => $workh->{name},
                id => $workh->{_id},
                vacation_plus => $workh->{vacation_plus},
                workday_plus => $workh->{workday_plus},
                weekend_plus => $workh->{weekend_plus}});
        }

        $self->stash(workhours => $workhours);
        return $self->render;
    }

    $log->debug("Store new employee");
    my $empl = {};
    $empl->{lastname} = $self->param('lastname');
    $empl->{firstname} = $self->param('firstname');
    $empl->{vacation} = $self->param('vacation');
    $empl->{total_work_time} = $self->param('total_work_time');
    $empl->{work_start} = $self->param('work_start');
    $empl->{work_shift} = $self->param('work_shift');

    my $mongo = $self->app->{mongo};
    $mongo->insert('employee', $empl);
    $self->redirect_to('/employee/list');
}


sub delete_employee {
    my $self = shift;

    my $log = $self->app->log;
    my $employee_id = $self->param('employee_id');

    my $mongo = $self->app->{mongo};
    $mongo->delete('employee', $employee_id);
    $self->redirect_to('/employee/list');
    
}

sub getlocaldata {
    my $self = shift;

    my $employees = $self->app->{mongo}->find('employee', {});

    my $json = {};
    $json->{employees} = {};
    while(my $em = $employees->next) {
        $json->{employees}->{$em->{_id}->to_string} = { firstname => $em->{firstname},
            lastname => $em->{lastname},
            id => $em->{_id}->to_string,
            work_shift => $em->{work_shift},
        };
    }

    my $workshifts_cursor = $self->app->{mongo}->find('work_hour', {});
    
    $json->{workshifts} = {};
    while(my $ws = $workshifts_cursor->next) {
        $json->{workshifts}->{$ws->{_id}->to_string} = {
            id => $ws->{_id}->to_string,
            name => $ws->{name},
            workday_plus => $ws->{workday_plus},
            weekend_plus => $ws->{weekend_plus},
            vacation_plus => $ws->{vacation_plus},
        };
    }

    $self->render(json => $json);
}

1;
