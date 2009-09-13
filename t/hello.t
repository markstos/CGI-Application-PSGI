use lib "t/lib";
use Test::More;

use Hello;
use CGI::Application::PSGI;

my $app = sub { CGI::Application::PSGI->run(Hello->new, @_) };

# FIXME replace this with Plackup
warn "http://localhost:8080/";
my $impl = $ENV{PSGI_IMPL};
if ($impl eq 'ServerSimple') {
    require PSGIRef::Impl::ServerSimple;
    my $server = PSGIRef::Impl::ServerSimple->new(8080);
    $server->psgi_app($app);
    $server->run;
} elsif ($impl eq 'Mojo') {
    require PSGIRef::Impl::Mojo;
    require Mojo::Server::Daemon;
    my $daemon = Mojo::Server::Daemon->new;
    $daemon->port(8080);
    PSGIRef::Impl::Mojo->start($daemon, $app);
}
