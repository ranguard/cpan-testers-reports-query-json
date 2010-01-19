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
    {   name         => 'Data Pageset - pass',
        distribution => 'Data::Pageset',
        version      => 1.04,
        json_url   => 'http://www.cpantesters.org/distro/D/Data-Pageset.json',
        total_fail => 0,
    },

    {   name         => 'Data Pageset - fail',
        distribution => 'Data::Pageset',
        version      => 1.04,
        json_url   => 'http://www.cpantesters.org/distro/D/Data-Pageset.json',
        total_fail => 1,
        fail_conf  => {
            windows_failed     => 0,
            non_windows_failed => 1
        }
    },

);

foreach my $test (@tests) {

    ok( 1, "$test->{name} tests" );
    my $dist_query = CTRQJTester->new(
        {   distribution => $test->{distribution},
            version      => $test->{version},
        }
    );
    is( ref($dist_query),      'CTRQJTester',     'Got object back' );
    is( $dist_query->json_url, $test->{json_url}, "JSON urls match" );
    
    my $all = $dist_query->all();
    
    # ok( $dist_query->number_failed() == $test->{total_fail},
    #         'Correct number of fails' );
    #     if ( $test->{total_fail} ) {
    # 
    #         #    windows_failed
    #         is( $dist_query->windows_failed,
    #             $test->{fail_conf}->{windows_failed},
    #             'Matched window fails'
    #         );
    # 
    #         # Non-window fails
    #         is( $dist_query->non_windows_failed,
    #             $test->{fail_conf}->{non_windows_failed},
    #             'Matched non window fails'
    #         );
    # 
    #     }
}
