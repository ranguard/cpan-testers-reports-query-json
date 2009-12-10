package CPAN::Testers::Reports::Query::JSON;

use strict;
use warnings;
use Carp;

use version;

use base qw(Class::Accessor::Faster);

use LWP::Simple;
use CPAN::Testers::WWW::Reports::Parser;

my @methods = qw(distribution version parser);

__PACKAGE__->mk_accessors(@methods);

our $VERSION = '0.01';

my %window_oses = (
    'MSWin32' => 1,
    'cygwin'  => 1,
);

=HEAD1 NAME
 
  CPAN::Testers::Reports::Query::JSON - Find out about a distributions cpantesters results
  
=head1 SYNOPSIS

  my $dist_query = CPAN::Testers::Reports::Query::JSON->new({
    distribution => 'Data::Pageset',
    version => '1.01', # optional, will default to latest version
  });s
  
  print "All passed\n" if $dist_query->number_failed() == 0;
  
  print "Non windows passwd\n" if $dist_query->non_windows_failed();
  
  print "Windows passwd\n" if $dist_query->windows_failed();
  
  # Return a CPAN::Testers::WWW::Reports::Parser object
  my $parser = $dist_query->get_parser();
  
=head1 DESCRIPTION

This module queries the cpantesters website (via the JSON interface) and 
gets the test results back, it then parses these to answer a few simple questions.

=cut

sub windows_failed {
    my $self = shift;

    return $self->number_failed( { os_include_only => \%window_oses, } );

}

sub non_windows_failed {
    my $self = shift;

    return $self->number_failed( { os_exclude => \%window_oses } );

}

=head2 number_failed

my $failed = $dist_query->number_failed( { os_include_only => { '', } } );

my $failed = $dist_query->number_failed(
    {
        os_exclude => { '', },
    }
);

  
=cut

sub number_failed {
    my ( $self, $conf ) = @_;
    $conf ||= {};

    my $number_failed = 0;
    my $parser        = $self->get_parser();

    foreach my $data ( @{ $self->_get_data_for_version() } ) {

        # Only want non-patched Perl at the moment
        next if $data->csspatch() ne 'unp';
        if ( $conf->{os_exclude} ) {
            next if $conf->{os_exclude}->{ $data->osname() };
        }
        if ( $conf->{os_include_only} ) {

            next unless $conf->{os_include_only}->{ $data->osname() };
        }

        $number_failed++ unless $data->state eq 'pass';
    }
    return $number_failed;
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

    return $self->version($max_version);
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
        format         => 'JSON',    # or 'JSON'
        data           => $data,
        report_objects => 1,
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
    return get( $self->json_url() );
}

1;
