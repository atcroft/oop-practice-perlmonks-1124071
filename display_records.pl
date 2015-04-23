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

my ( $search_active, $search_episodes, $search_year, @search_basis, @search_company, @search_title, @search_type, );
GetOptions(
    q{active=i}   => \$search_active,
    q{basis=s}    => \@search_basis,
    q{company=s}  => \@search_company,
    q{episodes=s} => \$search_episodes,
    q{title=s}    => \@search_title,
    q{type=s}     => \@search_type,
    q{help|?}     => \&help,
);

# print Data::Dumper->Dump(
#     [ \$search_active, \$search_episodes, \$search_year, \@search_basis, \@search_company, \@search_title, ],
#     [qw( *active *episodes *year *basis *company *title )] ),
#   qq{\n};
# exit;

my @list;
@list = load_data(q{./data.csv});

# print Data::Dumper->Dump( [ \@list, ], [qw( *list )] ), qq{\n};

print join( q{|}, q{Title}, q{Type}, q{Is active?}, q{Year(s)}, q{Based on}, q{Company}, q{Episodes}, ), qq{\n};
foreach my $i ( 0 .. $#list ) {

    my $flag = 1;
    {
        if ( defined $search_active ) {
            $flag = 0 unless ( $list[$i]->is_active == $search_active );
        }
        if ( scalar @search_basis ) {
            my $tflag = 0;
            my $data  = $list[$i]->get( q{based_on}, );
            foreach my $str (@search_basis) {
                if ( $data =~ m/\b${str}\b/i ) {
                    $tflag = 1;
                    last;
                }
            }
            $flag = $tflag;
        }
        if ( scalar @search_company ) {
            my $tflag = 0;
            my $data  = $list[$i]->get( q{company}, );
            foreach my $str (@search_company) {
                if ( $data =~ m/\b${str}\b/i ) {
                    $tflag = 1;
                    last;
                }
            }
            $flag = $tflag;
        }
        if ( scalar @search_title ) {
            my $tflag = 0;
            my $data  = $list[$i]->get( q{title}, );
            foreach my $str (@search_title) {
                if ( $data =~ m/\b${str}\b/i ) {
                    $tflag = 1;
                    last;
                }
            }
            $flag = $tflag;
        }
        if ( scalar @search_type ) {
            my $tflag = 0;
            my $data  = $list[$i]->what_is;
            foreach my $str (@search_type) {
                if ( $data =~ m/\b${str}\b/i ) {
                    $tflag = 1;
                    last;
                }
            }
            $flag = $tflag;
        }
        if ( defined $search_episodes ) {
            if ( not( defined $list[$i]->episodes and length $list[$i]->episodes ) ) {

                # print Data::Dumper->Dump( [ \$i, \$list[$i], ], [qw( *i *list[$i] )] ), qq{\n};
                $flag = 0;
                next;
            }

            my $search_episode_value = $search_episodes || 0;

            if ( length $search_episode_value ) {
                $search_episode_value =~ s/\D//g;
                if ( $search_episodes =~ m/\+/ ) {
                    $flag = ( $list[$i]->episodes > $search_episode_value );
                }
                elsif ( $search_episodes =~ m/\-/ ) {
                    $flag = ( $list[$i]->episodes < $search_episode_value );
                }
                else {
                    $flag = ( $list[$i]->episodes == $search_episode_value );
                }
            }
        }
    }
    next unless ($flag);

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
                    episodes => $row->[6],
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

sub help {

    print <<HELP_DATA;
$0 [--active=n] [--basis=str] [--company=str] \
    [--episodes=[+/-]n] [--title=str] [--year=[+/-]nnnn]
    [--help]

    --active=n          - (TV) if series is(1)/is not(0) active
    --basis=str         - basis containing this string
    --company=str       - company containing this string
    --episodes=[+/-]n   - if this many episodes 
                            (modifiers: 
                                '-' less than or equal; 
                                '+' greater than or equal;
                                neither - exactly this number of episodes)
    --title=str         - title containing this string
    --help              - display this help output
HELP_DATA

    exit;
}
