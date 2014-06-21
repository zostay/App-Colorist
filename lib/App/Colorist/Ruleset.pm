package App::Colorist::Ruleset;
use Moose ();
use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    as_is => [ qw( ruleset rule ) ],
);

our $BUILDING_RULESET;

sub ruleset(&) {
    my $code = shift;

    $BUILDING_RULESET = [];
    $code->();
    
    my $r = $BUILDING_RULESET;
    undef $BUILDING_RULESET;

    return $r;
}

sub rule {
    my ($regex, @names) = @_;
    push @$BUILDING_RULESET, $regex, \@names;
}

1;
