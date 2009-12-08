#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib t /home/leo/git/CPAN-Testers-WWW-Reports-Parser/lib);
use Test::More qw(no_plan);

BEGIN {
    use_ok("CPAN::Testers::Reports::Query::JSON");
    use_ok("CTRQJTester");
}

my @tests = (
    {   name         => 'Data Pageset - pass',
        distribution => 'Data::Pageset',
        json_url   => 'http://www.cpantesters.org/distro/D/Data-Pageset.json',
        total_fail => 0,
    },

    {   name         => 'Data Pageset - fail',
        distribution => 'Data::Pageset',
        version      => 1.04,
        json_url   => 'http://www.cpantesters.org/distro/D/Data-Pageset.json',
        total_fail => 1,
        fail_conf => {
            
        }
    },

);

foreach my $test (@tests) {

    ok( 1, "$test->{name} tests" );
    my $dist_query = CTRQJTester->new(
        {   distribution => $test->{distribution},
            version      => $test->{version} || undef,
        }
    );
    is( ref($dist_query),      'CTRQJTester',     'Got object back' );
    is( $dist_query->json_url, $test->{json_url}, "JSON urls match" );
    ok( $dist_query->number_failed() == $test->{total_fail}, 'Correct number of fails' );

}
