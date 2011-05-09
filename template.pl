#!/usr/bin/perl
use strict;
use warnings;

use IO::File; # from CPAN
use List::Util qw( first ); # perl core

my $config_file = shift || die "Usage: perl $0 config_filename.txt";
my $config = parse_config_file($config_file) || die "couldn't load config from $config_file";

my @report;
foreach my $case (@{$config})
{
    push @report, 'Case #'.$case->{number}.': ';
}
print join "\n", @report;


sub parse_config_file
{
    my $fh = IO::File->new(shift);

    my $number_of_cases = <$fh>;
    my $config = [];

    for (my $i=1; $i<=$number_of_cases; $i++)
    {
        my $case = {number => $i}; # for reporting

        push @{$config}, $case;
    }

    return $config;
}
