#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib);
use Test::More qw(no_plan);

BEGIN { use_ok("CPAN::Testers::Reports::Query::JSON") }

my @tests = (
    {   name         => 'Data Pageset - pass',
        distribution => 'Data::Pageset',
        json_url => 'http://www.cpantesters.org/distro/D/Data-Pageset.json'
    },

);

foreach my $test (@tests) {

    ok( 1, "$test->{name} tests" );
    my $query = CPAN::Testers::Reports::Query::JSON->new(
        { distribution => $test->{distribution}, } );
    is( ref($query),
        'CPAN::Testers::Reports::Query::JSON',
        'Got object back'
    );
    is( $query->json_url, $test->{json_url}, "JSON urls match" );

}
