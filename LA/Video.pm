package LA::Video;

use 5.014004;
use strict;
use warnings;
use Carp;
use Data::Dumper;

require Exporter;

our @ISA = qw(Exporter);

our $VERSION = '0.01';

sub new {
    my $self = shift;
    my $class = ref($self) || $self;

    my $hash = {};

    while ( scalar @_ ) {
        my $param = shift;
        if ( ref($param) eq q{HASH} ) {
            foreach my $k ( keys %{$param} ) {
                $hash->{$k} = $param->{$k};
            }
        }
        else {
            my $param2 = shift;
            $hash->{$param} = $param2;
        }
    }

    return bless $hash, $class;
}

sub get {
    my $self  = shift;
    my $param = shift;

    # print __LINE__, q{: }, Data::Dumper->Dump( [ \$self, \$param, \@_, ], [ qw( *self *param *_ ) ] ), qq{\n};
    if ( not scalar @_ ) {
        if ( not defined $self->{$param} ) {
            return undef;
        }
        return $self->{$param};
    }
    my $val = $self->{$param};
    while ( scalar @_ ) {
        my $key = shift;
        $val = $val->{$key};
    }
    return $val;
}

sub set {
    my $self  = shift;
    my $param = shift;

    if ( ref($param) eq q{HASH} ) {
        foreach my $k ( keys( %{$param} ) ) {
            $self->{$k} = $param->{$k};
        }
    }
    else {
        my $param2 = shift;
        $self->{$param} = $param2;
    }
}

sub episodes {
    my $self = shift;
    return undef;
}

sub is_active {
    my $self = shift;
    my @lt   = localtime;
    $lt[5] += 1900;
    my $years = $self->get(q{year});
    if ( defined $years->{end} ) {
        return $years->{end} eq $lt[5] ? 1 : 0;
    }
    return 0;
}

sub what_is {
    my $self = shift;
    my $type = ref $self;
    if ( not defined $type ) {
        return undef;
    }
    $type =~ s/.+:://g;
    return $type;
}

sub year_range {
    my $self       = shift;
    my $year_range = q{};
    if ( defined $self->get( q{year}, q{start}, ) ) {
        $year_range .= $self->get( q{year}, q{start}, );
    }
    if ( $self->is_active or ( defined $self->get( q{year}, q{end}, ) and length( $self->get( q{year}, q{end}, ) ) ) ) {
        $year_range .= q{-};
    }
    if ( defined $self->get( q{year}, q{end}, ) ) {
        $year_range .= $self->get( q{year}, q{end}, );
    }
    return $year_range;
}

1;
__END__
