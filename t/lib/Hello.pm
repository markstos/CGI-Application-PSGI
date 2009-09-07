package Hello;
use base qw(CGI::Application);

sub setup {
    my $self = shift;
    $self->start_mode('hello');
    $self->run_modes('hello' => 'hello');
}

sub hello {
    my $self = shift;

    my $query = $self->query;
    return "Hello " . $query->param('name');
}

1;

