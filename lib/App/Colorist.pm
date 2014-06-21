package App::Colorist;
use Moose;

with 'MooseX::Getopt';

use App::Colorist::Colorizer;

use IPC::Open3;

# ABSTRACT: Add color to your plain old outputs

=head2 SYNOPSIS

  # See the manual for colorist for command-line info
  alias cpanm="colorist cpanm"
  cpanm App::Colorist

  # OOOH! Look at the pretty colors!

=head1 DESCRIPTION

This documentation is primarily concerned with the installation of the application and giving an in-depth description  of the configuration of colorist rulesets and colorsets. For more information about the command-line options, see L<colorist>.

B<Installer Beware.> This application is still early in development, so please be aware that any upgrade might drastically change the way the program is used.

=cut

has configuration => (
    is          => 'ro',
    isa         => 'Str',
    traits      => [ 'Getopt' ],
    cmd_aliases => [ qw(c) ],
    lazy_build  => 1,
);

sub _build_configuration {
    my $self = shift;

    return $self->extra_argv->[0] if $self->execute;
    return;
}

has ruleset => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    traits      => [ 'Getopt' ],
    cmd_aliases => [ qw(R) ],
    default     => 'rules',
);

has colorset => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    traits      => [ 'Getopt' ],
    cmd_aliases => [ qw(C) ],
    default     => 'colors',
);

has include => (
    is          => 'ro',
    isa         => 'ArrayRef',
    required    => 1,
    traits      => [ 'Getopt' ],
    cmd_aliases => [ qw(I) ],
    default     => sub { [] },
);

has debug => (
    is          => 'ro',
    isa         => 'Bool',
    required    => 1,
    default     => 0,
);

has execute => (
    is          => 'ro',
    isa         => 'Bool',
    traits      => [ 'Getopt' ],
    cmd_aliases => [ qw(e) ],
    lazy_build  => 1,
);

sub _build_execute {
    my $self = shift;
    return $self->stderr ? 1 : 0;
}

has stderr => (
    is          => 'ro',
    isa         => 'Bool',
    required    => 1,
    traits      => [ 'Getopt' ],
    cmd_aliases => [ qw(E) ],
    default     => 0,
);

# I would like to have this someday...
# has follow => (
#     is          => 'ro',
#     isa         => 'Bool',
#     required    => 1,
#     default     => 0,
# );

has _colorizer => (
    reader      => 'colorizer',
    isa         => 'App::Colorist::Colorizer',
    lazy_build  => 1,
    handles     => [ 'run' ],
);

sub _build__colorizer {
    my $self = shift;

    my @args = @{ $self->extra_argv };

    my %params;

    # The command-line contains the command to run and arguments to it
    if ($self->execute) {

        # They have asked us to capture STDERR too
        if ($self->stderr) {
            open3('<&STDIN', my $outfh, my $errfh, @args);
            $params{inputs} = [ $outfh, $errfh ];
        }

        # They have asked us to capture just STDOUT
        else {
            open my $fh, '-|', @args or die "cannot execute ", join(' ', @args), ": ", $!;
            $params{inputs} = [ $fh ];
        }
    }

    # Otherwise, we use the default input reading from ARGV

    return App::Colorist::Colorizer->new(
        configuration => $self->configuration,
        ruleset       => $self->ruleset,
        colorset      => $self->colorset,
        include       => $self->include,
        debug         => $self->debug,
        %params,
    );
}

sub BUILD {
    my $self = shift;

    # This makes sure that <ARGV> works
    @ARGV = @{ $self->extra_argv };
}

=head1 QUICK START

If you just want to start using this with some canned configurations, here's the quick way to get started.

  # install colorist
  cpanm App::Colorist

  # clone the shared configuration from github
  git clone git://github.com/zostay/dot-colorist.git ~/.colorist

  # update your bashrc to setup the aliases you need
  echo 'source $HOME/.colorist/bashrc' > ~/.bashrc

After you are done you can logout and log back in or try running:

  source ~/.bashrc

After that, you can update your configuration to the latest just by pulling the latest configuration from github:

  # make sure colorist is up-to-date first
  cpanm App::Colorist

  # update your configuration
  cd ~/.colorist
  git pull

For more details on writing your own colorist configurations or customizing existing ones, you may read on.

=head1 CONFIGURATION

The configuration of colorist happens from a number of sources. First, the options passed to the command determine which configuration to use and where to find it, there's an environment variable to help with that as well, then a set of at least 2 configuration files is read to determine how to break up the input for adding color and what colors to add.

=head2 Finding Configuration

The first step in configuring colorist is to locate the configuration files. Without any special files or handling, colorist will normally look first in the current users's F<~/.colorist> directory for configuration and then into the F</etc/colorist> directory for the system.

The search order can be modified in two ways. One you can put additional search paths into the C<COLORIST_CONFIG> environment variable, like this:

  # assuming bash or something bash-ish
  export COLORIST_CONFIG=/opt/etc/colorist:/var/app/common/config/colorist

The C<COLORIST_CONFIG> variable is a colon-separated list of paths to search.

The other way to modify the search order is using the C<--include> option on the command-line. For example, these include options are roughly equivalent to the environment variable shown above:

  --include /opt/etc/colorist --incude /var/app/common/config/colorist

The search paths are configuration I<directories>, which may each contain zero or more rule sets and zero or more color sets for each rule set.

B<N.B.> The search order of directories is currently experimental and could change.

=head2 Configuration Directory

Inside the colorist configuration directory are zero or more other directories, each named for the ruleset to use to parse a command.

=cut

__PACKAGE__->meta->make_immutable;
