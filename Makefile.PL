use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'CPAN::Testers::Reports::Query::JSON',
    VERSION_FROM => 'lib/CPAN/Testers/Reports/Query/JSON.pm',
    PREREQ_PM    => {
        'Carp'                                => 0,
        'JSON::Any'                           => 0,
        'LWP::Simple'                         => 0,
        'Moose'                               => 0,
        'Test::More'                          => 0,
        'CPAN::Testers::WWW::Reports::Parser' => 0.02,
        'version'                             => 0,
    },
);

