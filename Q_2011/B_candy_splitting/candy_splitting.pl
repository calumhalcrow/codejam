#!/usr/bin/perl
use strict;
use warnings;

use 5.010;
use IO::File; # from CPAN
use Data::PowerSet qw( powerset ); # from CPAN
use List::Util qw( max sum ); # Perl core

my $config_file = shift || die "Usage: perl $0 config_filename.txt";
my $config = parse_config_file($config_file) || die "couldn't load config from $config_file";


my @report;
foreach my $case (@{$config})
{
    my $sean_will_get = calc_max_sean_can_get($case) || 'NO';
    push @report, 'Case #'.$case->{number}.': '.$sean_will_get;
}
print join "\n", @report;


sub calc_max_sean_can_get
{
    my $case = shift;
    my @values = @{$case->{values}};
    my $max_sean_can_get = 0;

    # All "proper" subsets; no null or full set.
    # powerset maintains element order in subsets.
    my $piles_ref = powerset({min => 1, max => scalar(@values) - 1}, @values);
    my @piles = @{$piles_ref};

    while (my $pile = shift @piles)
    {
        my @inverse = get_inverse(\@values, $pile);

        # remove inverse so that we don't check it later
        # @piles = grep { not @inverse ~~ @{$_} } @piles;

        if (patrick_sum(@{$pile}) == patrick_sum(@inverse))
        {
            $max_sean_can_get = max($max_sean_can_get, sum(@{$pile}), sum(@inverse));
        }
    }

    return $max_sean_can_get;
}


sub get_inverse
{
    my ($set_ref, $subset_ref) = @_;

    my @set = sort @{$set_ref};
    my @subset = sort @{$subset_ref};
    my @inverse;

    foreach my $elt (@set)
    {
        if (grep { $elt == $_ } @subset)
        {
            # can do this since the arrays are sorted
            shift @subset;
        }
        else
        {
            push @inverse, $elt;
        }
    }

    return @inverse;
}


sub patrick_sum
{
    my @pile = @_;

    my $total_bin = sprintf "%b", shift @pile;

    foreach my $value (@pile)
    {
        my $value_bin =  sprintf "%b", $value;
        my $sum_bin = "";

        while (length $value_bin or length $total_bin)
        {
            my $value_last = ($value_bin =~ s/([01])$//) ? $1 : 0;
            my $total_last = ($total_bin =~ s/([01])$//) ? $1 : 0;

            $sum_bin = (($value_last + $total_last) % 2) . $sum_bin;
        }

        $total_bin = $sum_bin;
    }

    return oct "0b$total_bin";
}


sub parse_config_file
{
    my $fh = IO::File->new(shift);

    my $number_of_cases = <$fh>;
    my $config = [];

    for (my $i=1; $i<=$number_of_cases; $i++)
    {
        my $number_of_sweets = int <$fh>;
        my @values = map { int } (split /\s/, <$fh>);

        push @{$config}, {values => \@values, number => $i};
    }

    return $config;
}
