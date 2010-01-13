package CPAN::Testers::Reports::Query::JSON::Set;
use Moose;

has total_tests    => ( isa => 'Str', is => 'ro', );
has number_passed  => ( isa => 'Str', is => 'ro', );
has number_failed  => ( isa => 'Str', is => 'ro', );
has percent_passed => ( isa => 'Str', is => 'ro', );

1;
