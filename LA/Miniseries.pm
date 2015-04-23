package LA::Miniseries;

use 5.014004;
use strict;
use warnings;
use Carp;
use Data::Dumper;

require Exporter;

our @ISA = qw(LA::Video);

our $VERSION = '0.01';

sub new {
    my $self = shift;
    my $class = ref($self) || $self;

    $class->SUPER::new( @_, { media => q{miniseries}, }, );
}

sub episodes {
    my $self = shift;
    return $self->get(q{episodes}) || -1;
}

1;
__END__
