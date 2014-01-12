#
#===============================================================================
#
#         FILE: Mongo.pm
#
#  DESCRIPTION: Wrapper for the MongoDB
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: wba (wolf), wbiker@gmx.at
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 07/12/13 20:25:42
#     REVISION: ---
#===============================================================================
package Database::Mongo;

use strict;
use warnings;
use Carp;
 
use MongoDB;

sub new {
    my $class = shift;
    my %options = @_;

    croak "'database' parameter is mendatory" unless exists $options{database};
    croak "'collections' array not set" unless exists $options{collections};

    my $self = {};
    if(exists $options{host}) {
        $self->{client} = MongoDB::MongoClient->new(host => $options{host});
    }
    else {
        $self->{client} = MongoDB::MongoClient->new;
    }
    
    $self->{db} = $self->{client}->get_database($options{database});

    for my $col (@{$options{collections}}) {
        $self->{collections}->{$col} = $self->{db}->get_collection($col);
    }
    
    return bless $self, $class;
}

sub insert {
    my $self = shift;
    my $collection = shift;
    my $hash = shift;

    $self->{collections}->{$collection}->insert($hash);

    return;
}

sub update {
    my $self = shift;
    my $collection = shift;
    my $criteria = shift;
    my $hash = shift;

    $self->{collections}->{$collection}->update($criteria, $hash);
}

sub find {
    my $self = shift;
    my $collection = shift;
    my $criteria = shift;

    my $find = $self->{collections}->{$collection}->find($criteria);
    return $find;
}

1;
