package CGI::Application::PSGI;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use base qw( CGI::Application );
use CGI::PSGI;

sub cgiapp_init {
    my $self = shift;
    my($env) = @_;

    $self->{_psgi_env} = $env;
}

sub cgiapp_get_query {
    my $self = shift;
    CGI::PSGI->new($self->{_psgi_env});
}

sub _send_headers { '' }

sub run {
    my $self = shift;
    $ENV{CGI_APP_RETURN_ONLY} = 1;
    my $super = "SUPER::run";
    my $body = $self->$super(@_);

    my $q    = $self->query;
    my $type = $self->header_type;

    my @headers;
    if ($type eq 'redirect') {
        my %props = $self->header_props;
        $props{'-location'} ||= delete $props{'-url'} || delete $props{'-uri'};
        @headers = $q->psgi_header(-Status => 302, %props);
    } elsif ($type eq 'header') {
        @headers = $q->psgi_header($self->header_props);
    } else {
        Carp::croak("Invalid header_type '$type'");
    }

    return [ @headers, [ $body ] ];
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

CGI::Application::PSGI - PSGI Adapter for CGI::Application

=head1 SYNOPSIS

  ### In WebApp.pm
  package WebApp;
  use base qw(CGI::Application::PSGI); # <- change this

  # Nothing else needs to be changed

  ### app.psgi
  use CGI::Application::PSGI;
  use WebApp;

  my $app = sub {
      my $env = shift;
      WebApp->new($env)->run;
  };

=head1 DESCRIPTION

CGI::Application::PSGI is a new CGI::Application subclass to run
existent CGI::Application web application as a PSGI application.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CGI::PSGI> L<CGI::Application::PSGI>

=cut
