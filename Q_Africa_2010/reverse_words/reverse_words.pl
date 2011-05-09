#!/usr/bin/perl
use strict;
use warnings;

use IO::File; # from CPAN
# use List::Util qw( first ); # perl core

my $config_file = shift || die "Usage: perl $0 config_filename.txt";
my $config = parse_config_file($config_file) || die "couldn't load config from $config_file";

my @report;

foreach my $case (@{$config})
{
    my @reversed = reverse @{$case->{words}};
    push @report, 'Case #'.$case->{number}.': '.join(' ', @reversed);
}

print join "\n", @report;

sub parse_config_file
{
    my $fh = IO::File->new(shift);

    my $number_of_cases = <$fh>;
    my $config = [];

    for (my $j=1; $j<=$number_of_cases; $j++)
    {
        my @words = (split /\s/, <$fh>);

        my $case = {
            number => $j,       # for reporting
            words  => \@words,
        };

        push @{$config}, $case;
    }

    return $config;
}
