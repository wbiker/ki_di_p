package KiDiP::Employee;
use Mojo::Base 'Mojolicious::Controller';

use Database::Mongo;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;
use PDF::Create;

# This action will render a template
sub list {
  my $self = shift;
    
  my $log = $self->app->log;
  my $mongo = $self->app->{mongo};
  $log->info("list action called");
  my $employees = $mongo->find('employee', {});

    my @empl;
    while(my $employee = $employees->next) {
        push(@empl, $employee);
    }
    
    @empl = sort { $a->{position} <=> $b->{position} } @empl;

  # Render template "employee/list.html.ep" with message
  $self->stash(employees => \@empl);
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
    $empl->{position} = $self->param('position');

    $mongo->update('employee', $employee_id, $empl);
    $self->redirect_to('/employee/list');
}

sub update_employee {
    my $self = shift;
    my $employee_id = $self->param('employee_id');
    $self->app->log->debug("update employee ID: $employee_id"); 

    my $mongo = $self->app->{mongo};
    my $data = $self->req->json;
    my $new_entry = {};
    for my $count (1..6) {
        my $key = "date".$count;
        my $date = $data->{$key};
#        if($date ne '' && $date ne '/') {
            my $date_string = $data->{"date".$count."_value"};
            my $already_exists = $mongo->find_field('workshift', {"date" => $date_string, employee_id => $data->{id}});

            $new_entry->{workshift} = $date;
            $new_entry->{employee_id} = $data->{id};
            $new_entry->{date} = $date_string;

            if(!$already_exists) {
                say "Insert new workshift: ", Dumper $new_entry;
                $mongo->insert('workshift', $new_entry);
            }
            else {
                say "Update existing workshift: ", Dumper $new_entry;
                $mongo->update('workshift', $already_exists->{_id}->to_string, $new_entry);
            }
 #       }
    }
    
    # update employee
    my $employee = $mongo->find_one('employee', $data->{id});
    if($employee) {
        $employee->{total_work_time} = $data->{total_work_time};
        $employee->{vacation} = $data->{vacation};
        $employee->{is_hours} = $data->{is_hours};

        $mongo->update('employee', $employee->{_id}->to_string, $employee);
    }

#    $mongo->update('employee', $employee_id, $empl);
    my $json = "{ status: 'OK'";
    $self->render(json => $json, status => 200);
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
                weekend_plus => $workh->{weekend_plus},
                });
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
    $empl->{position} = $self->param('position');

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

    my @wdays = qw/So Mo Di Mi Do Fr Sa/;
    # calculate days for one week
    my $cur = Time::Piece->new;
    # if current day is a monday I add one day because I want the next week not the current one.
    $cur += ONE_DAY if $cur->wday == 2;
    while($cur->wday != 2) {
        # asl long as date is not monday add one day
        $cur += ONE_DAY;
    }

    my $dates = {};
    for(1..7) {
        $dates->{'date'.$_} = $cur->ymd;
        $dates->{'date'.$_."_string"} = $wdays[$cur->day_of_week]." ".$cur->dmy('.');

        $cur += ONE_DAY;
    }

    $json->{dates} = $dates;

    $self->render(json => $json);
}

# triggered by /createpdf. called by the frontend if clicked on the Speichern button
sub createpdf {
    my $self = shift;
    my $log = $self->app->log;
    
    #my $date = $self->req->json;
    #my $file_name = $data->{data1};
}

1;
