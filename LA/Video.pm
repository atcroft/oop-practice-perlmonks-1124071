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

1;
__END__
