package ChronoRec::Provider::JIRA;

use Moose;
use MooseX::Types::URI 'Uri';

use JIRA::Client;

with 'ChronoRec::Role::Provider';

has client =>
	is          => 'ro',
	lazy_build  => 1;

has uri =>
	is			=> 'ro',
	isa			=> Uri,
	required	=> 1,
	coerce		=> 1;

has username =>
	is			=> 'ro',
	isa			=> 'Str',
	required	=> 1;

has password =>
	is			=> 'ro',
	isa			=> 'Str',
	required	=> 1;

has filter =>
	is			=> 'ro',
	isa			=> 'Str',
	required	=> 1;

has issues =>
	is			=> 'ro',
	isa			=> 'ArrayRef[Str]',
	lazy_build	=> 1;

has projects =>
	isa			=> 'ArrayRef[RemoteProject]',
	is			=> 'ro',
	lazy_build	=> 1;

sub _build_client
{
	my $self = shift;

	return new JIRA::Client $self->uri, $self->username, $self->password;
}

sub _build_projects
{
    my $self = shift;

	return $self->client
		? $self->client->getProjectsNoSchemes
		: [];
}

sub _build_issues
{
	my $self = shift;

	$self->client->set_filter_iterator($self->filter);

	my @issues = ();

	while (my $issue = $self->client->next_issue) {
		push @issues, $issue->{key};
	}

	return [ sort @issues ];
}

sub initialize
{
	shift->issues;
}

sub get_task_names
{
	my $self = shift;

	return @{ $self->issues };
}

sub write_sessions
{
}

1;

