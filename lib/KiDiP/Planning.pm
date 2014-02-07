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
    
  my $log = $self->app->log;
  $log->info("list action called");
  my $employees = $self->app->{mongo}->find('employee', {});
  my $work_hours = $self->app->{mongo}->find('work_hour', {});

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
    my $wh = $self->app->{mongo}->find_one('work_hour', $em->{work_shift});
    $em->{work_hour} = $wh;
    
    for my $cnt (1..7) {
        my $date = $dates->{'date'.$cnt};
        my $workshift = $self->app->{mongo}->find_field_and_employee_id('workshift', $em->{_id}->to_string, 'date', $date);
        if($workshift) {
            $em->{'date'.$cnt} = $workshift->{workshift};
        }
        else {
            $em->{'date'.$cnt} = "";
        }
    }


    push($empl, $em);
  }

  # Render template "employee/list.html.ep" with message
  $self->stash(employees => $empl);

  $self->stash(dates => $dates);

  $self->stash(workhours => $work_hours);
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}

1;
