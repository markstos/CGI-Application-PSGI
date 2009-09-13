package CGI::Application::PSGI;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use CGI::PSGI;

sub run {
	my $class = shift;
	my $self = shift;
	my $q = $self->query();

	my $rm_param = $self->mode_param();

	my $rm = $self->__get_runmode($rm_param);

	# Set get_current_runmode() for access by user later
	$self->{__CURRENT_RUNMODE} = $rm;

	# Allow prerun_mode to be changed
	delete($self->{__PRERUN_MODE_LOCKED});

	# Call PRE-RUN hook, now that we know the run mode
	# This hook can be used to provide run mode specific behaviors
	# before the run mode actually runs.
 	$self->call_hook('prerun', $rm);

	# Lock prerun_mode from being changed after cgiapp_prerun()
	$self->{__PRERUN_MODE_LOCKED} = 1;

	# If prerun_mode has been set, use it!
	my $prerun_mode = $self->prerun_mode();
	if (length($prerun_mode)) {
		$rm = $prerun_mode;
		$self->{__CURRENT_RUNMODE} = $rm;
	}

	# Process run mode!
	my $body = $self->__get_body($rm);

	# Support scalar-ref for body return
	$body = $$body if ref $body eq 'SCALAR';

	# Call cgiapp_postrun() hook
	$self->call_hook('postrun', \$body);

	# Set up HTTP headers
	my($status, $headers) = $self->_send_headers();

	# clean up operations
	$self->call_hook('teardown');

	return [ $status, $headers, [ $body ] ];
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

  use CGI::Application::PSGI;
  use WebApp;

  my $app = sub {
      my $env = shift;

      my $webapp = WebApp->new;
      local *ENV = $env;

      CGI::Application::PSGI->run($webapp);
  };

  # run $app with a PSGI implementation

=head1 DESCRIPTION

CGI::Application::PSGI is a runner to run existent CGI::Application web application as a PSGI application.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<CGI::PSGI> L<CGI::Application::PSGI>

=cut
