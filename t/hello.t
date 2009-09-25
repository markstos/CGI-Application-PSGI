use lib "t/lib";
use Test::More;
use Test::Requires qw(Plack::Loader);
use Test::TCP;
use LWP::UserAgent;

use Hello;
use CGI::Application::PSGI;

my $app = sub { Hello->new(@_)->run };

test_tcp(
    client => sub {
        my $port = shift;
        my $ua = LWP::UserAgent->new;
        my $res = $ua->get("http://127.0.0.1:$port/?name=bar");
        like $res->content, qr/Hello bar/;
        like $res->content_type, qr/plain/;

        $res = $ua->simple_request(HTTP::Request->new(GET => "http://127.0.0.1:$port/?rm=hello_redir"));
        is $res->code, 302;
        is $res->header('location'), '/foo';
    },
    server => sub {
        my $port = shift;
        Plack::Loader->auto(port => $port)->run($app);
    },
);

done_testing;
