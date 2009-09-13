package CGI::Application::PSGI;

use strict;
use 5.008_001;
our $VERSION = '0.01';

use IO::File;

sub run {
    my($class, $app, $env) = @_;

    local *ENV = $env;
    local *STDIN  = $env->{'psgi.input'};
    local *STDERR = $env->{'psgi.errors'};

    # ripped from HTTP::Request::AsCGI
    my $stdout = IO::File->new_tmpfile;
    open my $old_stdout, '>&'. STDOUT->fileno
        or die "Can't dup stdout: $!";
    open STDOUT, '>&='. $stdout->fileno
        or die "Can't open stdout: $!";
    binmode $stdout;
    binmode STDOUT;

    $app->run;

    STDOUT->flush
        or die "Can't flush stdout: $!";
    open STDOUT, '>&'. fileno($old_stdout)
        or die "Can't restore stdout: $!";

    sysseek( $stdout, 0, SEEK_SET )
        or die "Can't seek stdout: $!";

    # FIXME: read status and headers now

    return [ 200, [ 'Content-Type' => "text/html" ], $stdout ];
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

  # Nothing needs to be changes

  ### server
  use CGI::Application::PSGI;
  use WebApp;

  my $webapp = WebApp->new;
  my $app = sub { CGI::Application::PSGI->run($webapp, @_) };

  # run $app with a PSGI implementation

=head1 DESCRIPTION

CGI::Applicaition is a runner to run existent CGI::Application web application as a PSGI application.

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
