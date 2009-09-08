CGI::Application::PSGI is not needed right now, because Plack has an adapter for any CGI scripts, that really works well with CGI::Application.

See [Plack](http://github.com/miyagawa/Plack) and its Plack::Adapter::CGI. We also have a plan to add a direct PSGI support to CGI.pm itself.

