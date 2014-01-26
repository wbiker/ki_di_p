package KiDiP::Planning;
use Mojo::Base 'Mojolicious::Controller';

use Database::Mongo;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;

# This action will render a template
sub planning {
  my $self = shift;
    
  my $log = $self->app->log;
  $log->info("list action called");
  my $employees = $self->app->{mongo}->find('employee', {});
  # Render template "employee/list.html.ep" with message
  $self->stash(employees => $employees);

  # calculate days for one week
  my $cur = Time::Piece->new;
  while($cur->wday != 2) {
    # asl long as date is not monday add one day
    $cur += ONE_DAY;
  }

  my $dates = {};
  for(1..7) {
    $dates->{'date'.$_} = $cur->ymd;
    $dates->{'date'.$_."_string"} = $cur->dmy('.');

    $cur += ONE_DAY;
  }
  $self->stash(dates => $dates);

  my $work_hours = $self->app->{mongo}->find('work_hour', {});
  $self->stash(workhours => $work_hours);
  $self->render(
    message => 'Welcome to the Mojolicious real-time web framework!');
}

1;
