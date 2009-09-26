package CGI::Application::PSGI;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use CGI::PSGI;

sub run {
    my($class, $app) = @_;

    $ENV{CGI_APP_RETURN_ONLY} = 1;

    # save and reset header_type in postrun hook
    my $header_type;
    $app->add_callback('postrun', sub {
        my $self = shift;
        $header_type = $self->header_type;
        $self->header_type('none');
    });

    my $body = $app->run;
    my $q    = $app->query;

    my @headers;
    if ($header_type eq 'redirect') {
        my %props = $app->header_props;
        $props{'-location'} ||= delete $props{'-url'} || delete $props{'-uri'};
        @headers = $q->psgi_header(-Status => 302, %props);
    } elsif ($header_type eq 'header') {
        @headers = $q->psgi_header($app->header_props);
    } elsif ($header_type ne 'none') {
        Carp::croak("Invalid header_type '$header_type'");
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
  use base qw(CGI::Application);

  # Nothing needs to be changed

  ### app.psgi
  use CGI::Application::PSGI;
  use WebApp;

  my $handler = sub {
      my $env = shift;
      my $app = WebApp->new({ QUERY => CGI::PSGI->new($env) });
      CGI::Application::PSGI->run($app);
  };

=head1 DESCRIPTION

CGI::Application::PSGI is a runner to run CGI::Application application
as a PSGI application.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CGI::PSGI> L<CGI::Application::PSGI>

=cut
