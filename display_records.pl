#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;
use Text::CSV;

use LA::Video;
use LA::Film;
use LA::Miniseries;
use LA::TV;

$| = 1;
srand();

my @list;
@list = load_data(q{./data.csv});

# print Data::Dumper->Dump( [ \@list, ], [qw( *list )] ), qq{\n};

print join( q{|}, q{Title}, q{Type}, q{Is active?}, q{Year(s)}, q{Based on}, q{Company}, q{Episodes}, ), qq{\n};
foreach my $i ( 0 .. $#list ) {
    print join( q{|},
        $list[$i]->get(q{title}),
        $list[$i]->what_is,
        $list[$i]->is_active,
        $list[$i]->year_range,
        defined $list[$i]->get( q{based_on}, ) ? $list[$i]->get( q{based_on}, ) : q{},
        defined $list[$i]->get( q{company}, )  ? $list[$i]->get( q{company}, )  : q{},
        defined $list[$i]->get( q{episodes}, ) ? $list[$i]->get( q{episodes}, ) : q{},
      ),
      qq{\n};
}

#
# Subroutines
#
sub load_data {
    my ($fn) = @_;

    my @data;
    my $csv = Text::CSV->new( { binary => 1, }, )
      or die qq{Cannot use CSV: } . Text::CSV->error_diag();

    open my $fh, q{<:encoding(utf8)}, $fn, or die $!;
    while ( my $row = $csv->getline($fh) ) {
        next if ( $row->[0] =~ m/^\s*#/ );

        if ( $row->[1] =~ m/tv/i ) {
            push @data,
              LA::TV->new(
                {
                    title    => $row->[0],
                    year     => { start => $row->[2], end => defined $row->[3] ? $row->[3] : undef, },
                    based_on => $row->[4],
                    company  => $row->[5],
                    episodes => $row->[6],
                },
              );
        }
        elsif ( $row->[1] =~ m/miniseries/i ) {
            push @data,
              LA::Miniseries->new(
                {
                    title    => $row->[0],
                    year     => { start => $row->[2], end => defined $row->[3] ? $row->[3] : undef, },
                    based_on => $row->[4],
                    company  => $row->[5],
                },
              );
        }
        elsif ( $row->[1] =~ m/film/i ) {
            push @data,
              LA::Film->new(
                {
                    title    => $row->[0],
                    year     => { start => $row->[2], end => defined $row->[3] ? $row->[3] : undef, },
                    based_on => $row->[4],
                    company  => $row->[5],
                },
              );
        }
        else {
            push @data,
              LA::Video->new(
                {
                    title    => $row->[0],
                    media    => $row->[1],
                    year     => { start => $row->[2], end => defined $row->[3] ? $row->[3] : undef, },
                    based_on => $row->[4],
                    company  => $row->[5],
                },
              );
        }
    }
    $csv->eof or $csv->error_diag();
    close $fh;

    return @data;
}

