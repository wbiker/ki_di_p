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
    my $id = shift;
    my $hash = shift;

    my $iod = MongoDB::OID->new($id);

    $self->{collections}->{$collection}->update({_id => $iod}, $hash);
}

sub find {
    my $self = shift;
    my $collection = shift;
    my $criteria = shift;

    my $find = $self->{collections}->{$collection}->find($criteria);
    return $find;
}

sub find_one {
    my $self = shift;
    my $collection = shift;
    my $id = shift;
    
    my $oid;
    $oid = MongoDB::OID->new($id);
    my $find = $self->{collections}->{$collection}->find_one({_id => $oid});

    return $find;
}

sub find_field {
    my $self = shift;
    my $collection = shift;
    my $field = shift;
    my $value = shift;
    
    my $find = $self->{collections}->{$collection}->find_one({$field => $value});

    return $find;
}

sub find_field_and_employee_id {
    my $self = shift;
    my $collection = shift;
    my $eid = shift;
    my $field = shift;
    my $value = shift;
    
    my $find = $self->{collections}->{$collection}->find_one({'employee_id' => $eid, $field => $value});

    return $find;
}

sub delete {
    my $self = shift;
    my $collection = shift;
    my $id = shift;
    
    my $oid;
    $oid = MongoDB::OID->new($id);
    my $find = $self->{collections}->{$collection}->remove({_id => $oid});

    return $find;
}

1;
