#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib t /Users/leo/git/CPAN-Testers-WWW-Reports-Parser/lib);
use Test::More qw(no_plan);

BEGIN {
    use_ok("CPAN::Testers::Reports::Query::JSON");
    use_ok("CTRQJTester");
}

my @tests = (
    {   name         => 'Data Pageset',
        distribution => 'Data::Pageset',
        json_url   => 'http://www.cpantesters.org/distro/D/Data-Pageset.json',
        win32_only => {
            total_tests => 28,
            number_fail => 2,
        },
        non_win32 => {
            total_tests => 778,
            number_fail => 8,
        },
        all => {
            total_tests => 806,
            number_fail => 10,
        },
    },
);

foreach my $test (@tests) {

    ok( 1, "$test->{name} tests" );
    my $dist_query = CTRQJTester->new(
        {   distribution => $test->{distribution},
            version      => $test->{version} || '0',
        }
    );
    is( ref($dist_query),       'CTRQJTester',     'Got object back' );
    is( $dist_query->_json_url, $test->{json_url}, "JSON urls match" );

    #    foreach my $type (qw(all win32_only non_win32)) {
    foreach my $type (qw(all )) {
        my $test_set = $test->{$type};
        my $set      = $dist_query->$type();

        is( $set->total_tests(),
            $test_set->{total_tests},
            "total tests: $type"
        );
        is( $set->number_failed(),
            $test_set->{number_fail},
            "total fail: $type"
        );

    }
}
