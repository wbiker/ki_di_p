package KiDiP::Workhour;
use Mojo::Base 'Mojolicious::Controller';

use Database::Mongo;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;

# This action will render a template
sub list {
  my $self = shift;
  $self->redirect_to('login') unless $self->is_user_authenticated();
    
  my $log = $self->app->log;
  $log->info("list action called");
  my $mongo = $self->app->{mongo};
  my $wh = $mongo->work_hour->find({});
  # Render template "employee/list.html.ep" with message
  $self->stash(workhours => $wh);
}

sub new_workhour {
  my $self = shift;
  $self->redirect_to('login') unless $self->is_user_authenticated();

  my $mongo = $self->app->{mongo};
    
  my $log = $self->app->log;
  # Render template "employee/list.html.ep" with message
  if('GET' eq $self->req->method) {
      return $self->render;
  }

    # store new workhour
  my $wh = {};
  $wh->{name} = $self->param('name');
  $wh->{vacation_plus} = $self->param('vacation_plus');
  $wh->{weekend_plus} = $self->param('weekend_plus');
  $wh->{workday_plus} = $self->param('workday_plus');

  $mongo->work_hour->insert($wh);
}

1;
