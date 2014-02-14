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
use feature qw(say);
use Carp;
 
use MongoDB;
use vars qw/$AUTOLOAD/;

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
    $self->{desired_collection} = undef;

    for my $col (@{$options{collections}}) {
        $self->{collections}->{$col} = $self->{db}->get_collection($col);
    }
    
    return bless $self, $class;
}

sub insert {
    my $self = shift;
    my $hash = shift;
    my $collection = shift;

    unless($collection) {
        die "collection must be set either as methode or as parameter!" unless $self->{desired_collection};
        $collection = $self->{desired_collection};
    }

    $self->{collections}->{$collection}->insert($hash);

    return;
}

sub update {
    my $self = shift;
    my $id = shift;
    my $hash = shift;
    my $collection = shift;

    unless($collection) {
        die "collection must be set either as methode or as parameter!" unless $self->{desired_collection};
        $collection = $self->{desired_collection};
    }
    
    my $iod = MongoDB::OID->new($id);

    $self->{collections}->{$collection}->update({_id => $iod}, $hash);
}

sub find {
    my $self = shift;
    my $criteria = shift;
    my $collection = shift;

    unless($collection) {
        die "collection must be set either as methode or as parameter!" unless $self->{desired_collection};
        $collection = $self->{desired_collection};
    }
    
    my $find = $self->{collections}->{$collection}->find($criteria);
    return $find;
}

sub find_one {
    my $self = shift;
    my $id = shift;
    my $collection = shift;
    
    unless($collection) {
        die "collection must be set either as methode or as parameter!" unless $self->{desired_collection};
        $collection = $self->{desired_collection};
    }
    
    my $oid;
    $oid = MongoDB::OID->new($id);
    my $find = $self->{collections}->{$collection}->find_one({_id => $oid});

    return $find;
}

sub find_field {
    my $self = shift;
    my $hash = shift; 
    my $collection = shift;

    unless($collection) {
        die "collection must be set either as methode or as parameter!" unless $self->{desired_collection};
        $collection = $self->{desired_collection};
    }
    
    my $find = $self->{collections}->{$collection}->find_one($hash);

    return $find;
}

sub find_field_and_employee_id {
    my $self = shift;
    my $eid = shift;
    my $field = shift;
    my $value = shift;
    my $collection = shift;
    
    unless($collection) {
        die "collection must be set either as methode or as parameter!" unless $self->{desired_collection};
        $collection = $self->{desired_collection};
    }
    
    my $find = $self->{collections}->{$collection}->find_one({'employee_id' => $eid, $field => $value});

    return $find;
}

sub delete {
    my $self = shift;
    my $id = shift;
    my $collection = shift;
    
    unless($collection) {
        die "collection must be set either as methode or as parameter!" unless $self->{desired_collection};
        $collection = $self->{desired_collection};
    }
    
    my $oid;
    $oid = MongoDB::OID->new($id);
    my $find = $self->{collections}->{$collection}->remove({_id => $oid});

    return $find;
}

sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) or die "$self is not a object!";

    my $collection_name = $AUTOLOAD;
    $collection_name =~ s/.*://;

    if(exists $self->{collections}->{$collection_name}) {
        $self->{desired_collection} = $collection_name;
    }
    else {
        die "Could not found $collection_name in the collections";
    }
    return $self; 
}

1;
