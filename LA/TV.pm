package LA::TV;

use 5.014004;
use strict;
use warnings;
use Carp;
use Data::Dumper;

our @ISA = qw(LA::Video);

our $VERSION = '0.01';

sub new {
    my $self = shift;
    my $class = ref($self) || $self;

    $class->SUPER::new( @_, { media => q{tv}, }, );
}

sub episodes {
    my $self = shift;
    return $self->get(q{episodes}) || -1;
}

sub is_active {
    my $self = shift;
    my @lt   = localtime;
    $lt[5] += 1900;
    my $years = $self->get( q{year}, q{end}, );

    # print __LINE__, q{: }, Data::Dumper->Dump( [ \$years, ], [ qw( *years ) ] ), qq{\n};
    if ( defined $years and $years =~ m/\d+/ ) {
        return $years == $lt[5] ? 1 : 0;
    }
    $years = $self->get( q{year}, q{start}, );

    # print __LINE__, q{: }, Data::Dumper->Dump( [ \$years, ], [ qw( *years ) ] ), qq{\n};
    if ( defined $years and $years =~ m/\d+/ ) {
        return $years <= $lt[5] ? 1 : 0;
    }
    return 0;
}

1;
__END__
