#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;

use LA::Video;

$| = 1;
srand();

my @list;

push @list,
  LA::Video->new(
    {
        title => q{Criminal Minds},
        media => q{tv},
        year  => { start => 2005, },
    },
  );
push @list,
  LA::Video->new(
    {
        title => q{The 10th Kingdom},
        media => q{miniseries},
        year  => { start => 2000, },
    },
  );
push @list,
  LA::Video->new(
    {
        title    => q{Iron Man},
        media    => q{film},
        year     => { start => 2008, },
        based_on => q{comics},
        company  => q{Marvel Comics},
    },
  );
push @list,
  LA::Video->new(
    {
        title    => q{Tin Man},
        media    => q{miniseries},
        year     => { start => 2007, },
        based_on => q{novel},
        company  => q{L. Frank Braum},
    },
  );
push @list,
  LA::Video->new(
    {
        title    => q{The Avengers},
        media    => q{film},
        year     => { start => 1998, },
        based_on => q{television series},
        company  => q{Thames Television},
    },
  );

# print Data::Dumper->Dump( [ \@list, ], [qw( *list )] ), qq{\n};

foreach my $i ( 0 .. $#list ) {
    print join( q{|}, $list[$i]->get(q{title}), $list[$i]->what_is, $list[$i]->is_active, ), qq{\n};
}

