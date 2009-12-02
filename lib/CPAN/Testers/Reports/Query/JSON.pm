package CPAN::Testers::Reports::Query::JSON;

use Moose;
use Carp;
use LWP::Simple;
use CPAN::Testers::WWW::Reports::Parser;

our $VERSION = '0.01';

=HEAD1 NAME
 
  CPAN::Testers::Reports::Query::JSON - Find out about a distributions cpantesters results
  
=head1 SYNOPSIS

  my $dist_query = CPAN::Testers::Reports::Query::JSON->new({
    distribution => 'Data::Pageset',
    version => '1.01', # optional, will default to latest version
  });
  
  print "All passed\n" if $dist_query->all_passed();
  
  print "Non windows passwd\n" if $dist_query->non_windows_passed();
  
  print "Windows passwd\n" if $dist_query->windows_pass();
  
  # get the raw data for all results, or a specific version if supplied
  my $data = $dist_query->fetch_data($version);
  
=head1 DESCRIPTION

This module queries the cpantesters website (via the JSON interface) and 
gets the test results back, it then parses these to answer a few simple questions.

=cut

has 'distribution' => ( is => 'rw' );
has 'version'      => ( is => 'rw' );
has 'parser'       => ( is => 'rw' );

sub parse_data {
    my $self = shift;

    my $data = $self->raw_json();

    my $obj = CPAN::Testers::WWW::Reports::Parser->new(
        format => 'JSON',    # or 'JSON'
        data   => $data,
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
