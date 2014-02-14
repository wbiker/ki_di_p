package KiDiP::Planning;
use Mojo::Base 'Mojolicious::Controller';

use Database::Mongo;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;

my @wdays = qw(So Mo Di Mi Do Fr Sa);

# This action will render a template
sub planning {
  my $self = shift;
  $self->redirect_to('login') unless $self->is_user_authenticated();
    
  my $log = $self->app->log;
  $log->info("list action called");
  my $mongo = $self->app->{mongo};
  my $employees = $mongo->employee->find({});
  my $work_hours = $mongo->work_hour->find({});

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

  # walk through the employees and add the work hor data
  my $empl = [];
  while(my $em = $employees->next) {
    my $wh = $mongo->work_hour->find_one($em->{work_shift});
    $em->{work_hour} = $wh;
    
    my $workshift_found;
    for my $cnt (1..7) {
        my $date = $dates->{'date'.$cnt};
        my $workshift = $mongo->workshift->find_field_and_employee_id($em->{_id}->to_string, 'date', $date);
        if($workshift) {
            $em->{'date'.$cnt} = $workshift->{workshift};
            $workshift_found = 1;    # only if at least one workshift for this employee was found I use the is_hour value from the database. Otherwise is_hours is 0.
        }
        else {
            $em->{'date'.$cnt} = "";
        }
    }
   if(!$workshift_found) {
        # no workshift this week found. Set is_hours to 0.
       $em->{is_hours} = 0;
   }

    push($empl, $em);
  }
    # sort employees
    my @sorted_employees = sort { $a->{position} <=> $b->{position} } @{$empl};

  # Render template "employee/list.html.ep" with message
  $self->stash(employees => \@sorted_employees);

  $self->stash(dates => $dates);

  $self->stash(workhours => $work_hours);
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}

1;
