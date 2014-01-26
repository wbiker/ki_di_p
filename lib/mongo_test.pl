#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: mongo_test.pl
#
#        USAGE: ./mongo_test.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: wba (wolf), wbiker@gmx.at
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 08/12/13 16:16:15
#     REVISION: ---
#===============================================================================

use Modern::Perl;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Database::Mongo;

my $mono = Database::Mongo->new(database => 'kidip', collections => [qw/testrun/]);


my $command = $ARGV[0] // 'find';

if('find' eq $command) {
    say "Find command";
    my $find_parameter = $ARGV[1] // {};
    say "Find parameters: '$find_parameter'";
    my $array = $mono->find('testrun', {status => {'$in' => ['Passed']}} );

    if($array) {
        for my $row (@{$array}) {
            print Dumper $row;
        }
    }
    else {
        say "Did not get any results back";
    }
}
elsif('insert' eq $command) {
    say "Insert command";
    my $insert_paramter = $ARGV[1] or die "Insert needs parameter to work";
    my $name = $ARGV[1];
    my $status = $ARGV[2];
    $mono->insert('testrun', { name => $name, status => $status});
}
