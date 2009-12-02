#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib);
use Test::More qw(no_plan);

BEGIN { use_ok("CPAN::Testers::Query") }

my @tests = (
    {   name         => 'Data Pageset - pass',
        distribution => 'Data::Pageset',
        json_url => 'http://www.cpantesters.org/distro/D/Data-Pageset.json'
    },

);

foreach my $test (@tests) {

    ok( 1, "$test->{name} tests" );
    my $query = CPAN::Testers::Query->new(
        { distribution => $test->{distribution}, } );
    is( ref($query),      'CPAN::Testers::Query', 'Got object back' );
    is( $query->json_url, $test->{json_url},      "JSON urls match" );

    use Data::Dumper;
    local $Data::Dumper::Sortkeys = 1;
    warn Dumper( $query->json() );

}
