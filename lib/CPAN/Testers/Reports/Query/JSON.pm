package CPAN::Testers::Reports::Query::JSON;
use Moose;

use version;
use LWP::Simple;
use CPAN::Testers::WWW::Reports::Parser;
use CPAN::Testers::Reports::Query::JSON::Set;

has distribution => ( isa => 'Str', is => 'ro', );
has version      => ( is => 'rw' );
has parser       => (
    isa => 'Str',
    is  => 'rw',
    isa => 'CPAN::Testers::WWW::Reports::Parser'
);

our $VERSION = '0.01';

=HEAD1 NAME
 
  CPAN::Testers::Reports::Query::JSON - Find out about a distributions cpantesters results
  
=head1 SYNOPSIS

    my $dist_query = CPAN::Testers::Reports::Query::JSON->new(
        {   distribution => 'Data::Pageset',
            version => '1.01',    # optional, will default to latest version
        }
    );

    print "Processing version: " . $dist_query->version() . "\n";
    print "Other versions are: " . join(" ", @{$dist_query->versions()}) . "\n";

    my $all = $dist_query->all();
    printf "There were %s tests, %s passed, %s failed - e.g. %s percent",
        $all->total_tests(),
        $all->number_passed(),
        $all->number_failed(),
        $all->percent_passed();

    my $win32_only = $dist_query->win32_only();
    printf "There were %s windows tests, %s passed, %s failed - e.g. %s percent",
        $win32_only->total_tests(),
        $win32_only->number_passed(),
        $win32_only->number_failed(),
        $win32_only->percent_passed();

    my $non_win32 = $dist_query->non_win32();
    printf "There were %s windows tests, %s passed, %s failed - e.g. %s percent",
        $non_win32->total_tests(),
        $non_win32->number_passed(),
        $non_win32->number_failed(),
        $non_win32->percent_passed();

    # Return a CPAN::Testers::WWW::Reports::Parser object
    my $parser = $dist_query->get_parser();
  
=head1 DESCRIPTION

This module queries the cpantesters website (via the JSON interface) and 
gets the test results back, it then parses these to answer a few simple questions.

=cut

sub all {
    my $self = shift;

    return $self->_create_set();
}

sub win32_only {
    my $self = shift;

    return $self->_create_set(
        {   os_include_only => {
                'MSWin32' => 1,
                'cygwin'  => 1,
            },
        }
    );

}

sub non_win32 {
    my $self = shift;

    return $self->_create_set(
        {   os_exclude => {
                'MSWin32' => 1,
                'cygwin'  => 1,
            },
        }
    );

}

sub _create_set {
    my ( $self, $conf ) = @_;

    $conf ||= {};

    my $parser = $self->get_parser();

    my @os_data;

    foreach my $data ( @{ $self->_get_data_for_version() } ) {

        # Only want non-patched Perl at the moment
        next if $data->csspatch() ne 'unp';
        if ( $conf->{os_exclude} ) {
            next if $conf->{os_exclude}->{ $data->osname() };
        }
        if ( $conf->{os_include_only} ) {
            next unless $conf->{os_include_only}->{ $data->osname() };
        }
        push( @os_data, $data );
    }

    return CPAN::Testers::Reports::Query::JSON::Set->new(
        { data => \@os_data, } );
}

=head2 find_current_version

    my $current_version = $query->find_current_version();

Sets $query->version() and returns the largest version

=cut

sub find_current_version {
    my $self   = shift;
    my $parser = $self->get_parser();

    my $max_version = version->new('0');
    while ( my $data = $parser->report() ) {

        my $this_version = version->new( $data->version() );
        if ( $this_version > $max_version ) {
            $max_version = $self->version($this_version);
        }
    }

    return $self->version("$max_version");
}

sub _get_data_for_version {
    my $self    = shift;
    my $version = $self->version || $self->find_current_version;
    my $parser  = $self->get_parser();

    my @data;
    while ( my $data = $parser->report() ) {

        push( @data, $data ) if $data->version() eq $version;
    }
    return \@data;

}

sub get_parser {
    my $self = shift;
    $self->_get_parser() unless $self->parser();
    return $self->parser();
}

sub _get_parser {
    my $self = shift;

    my $data = $self->raw_json();

    my $obj = CPAN::Testers::WWW::Reports::Parser->new(
        format  => 'JSON',    # or 'JSON'
        data    => $data,
        objects => 1,
    );
    return $self->parser($obj);

}

sub json_url {
    my $self = shift;
    my $dist = $self->distribution();
    $dist =~ s/::/-/;
    my ($letter) = ( $dist =~ /(.{1})/ );

    return "http://www.cpantesters.org/distro/$letter/$dist.json";

}

sub raw_json {
    my $self = shift;

    # Fetch from website - could have caching here
    return get( $self->json_url() );
}

1;
