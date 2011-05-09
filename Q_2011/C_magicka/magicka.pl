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
    my @element_list = build_element_list($case);
    push @report, 'Case #'.$case->{number}.': ['.join(', ', @element_list).']';
}
print join "\n", @report;


sub build_element_list
{
    my $case = shift;
    my @final_elements;

    ELEMENT:
    foreach my $element (@{$case->{invokation}})
    {
        if (scalar @final_elements)
        {
            # combo?
            if (my $combo_element = get_combo($case, $element, $final_elements[-1]))
            {
                pop @final_elements;
                push @final_elements, $combo_element;
                next ELEMENT;
            }
            # opposition?
            elsif (grep { opposes($case, $element, $_) } @final_elements)
            {
                @final_elements = ();
                next ELEMENT;
            }
        }

        push @final_elements, $element;
    }

    return @final_elements;
}

sub get_combo
{
    my ($case, @elts) = @_;

    return $case->{combinations}->{$elts[0].$elts[1]} || $case->{combinations}->{$elts[1].$elts[0]};
}

sub opposes
{
    my ($case, @elts) = @_;

    if (grep { $_ eq $elts[0].$elts[1] or $_ eq $elts[1].$elts[0] } @{$case->{oppositions}})
    {
        return 1;
    }

    return;
}

sub parse_config_file
{
    my $fh = IO::File->new(shift);

    my $number_of_cases = <$fh>;
    my $config = [];

    for (my $i=1; $i<=$number_of_cases; $i++)
    {
        my $full_line = <$fh>;
        chomp $full_line;

        $full_line =~ s/^\d+//;

        my ($combs_str, $opps_str, $invok_str) = split /\d+/, $full_line;
        $combs_str = trim($combs_str);
        $opps_str  = trim($opps_str);
        $invok_str = trim($invok_str);

        my %combinations = map { /([QWERASDF]{2})([A-Z])/; $1 => $2 } (split /\s/, $combs_str);
        my @oppositions  = split /\s/, $opps_str;
        my @invokation   = grep {$_} (split /([QWERASDF])/, $invok_str);
        my $case = {
            number       => $i, # for reporting
            combinations => \%combinations,
            oppositions  => \@oppositions,
            invokation   => \@invokation,
        };

        push @{$config}, $case;
    }

    return $config;
}

sub trim
{
    my $string = shift;
    $string =~ s/^\s+|\s+$//g;
    return $string;
}
