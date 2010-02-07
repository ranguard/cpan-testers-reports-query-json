package CPAN::Testers::Reports::Query::JSON::Set;
use Moose;

has name           => ( isa => 'Str', is => 'ro', default => 'no-name' );
has total_tests    => ( isa => 'Int', is => 'rw', default => 0 );
has number_passed  => ( isa => 'Int', is => 'rw', default => 0 );
has number_failed  => ( isa => 'Str', is => 'rw', default => 0 );
has percent_passed => ( isa => 'Str', is => 'rw', default => 0 );
has data => ( isa => 'ArrayRef', is => 'rw', );

sub BUILD {
    my $self = shift;

    my $total_tests   = 0;
    my $number_failed = 0;

    # Go get the data
    foreach my $data ( @{ $self->data() } ) {
        $total_tests++;
        $number_failed++ unless $data->state eq 'pass';
    }
    return unless $total_tests;

    $self->total_tests($total_tests);
    $self->number_failed($number_failed);
    $self->number_passed( $total_tests - $number_failed );

    # calc percent
    $self->percent_passed( ( $self->number_passed() / $total_tests ) * 100 );
    # We don't need the data now
    $self->data( [] );
}

1;
