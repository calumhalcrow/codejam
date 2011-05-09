#!/usr/bin/perl
use strict;
use warnings;

use IO::File; # from CPAN

my $config_file = shift || die "Usage: perl $0 config_filename.txt";
my $config = parse_config_file($config_file) || die "couldn't load config from $config_file";



my @report;
foreach my $case (@{$config->{cases}})
{
    my $matches = count_matches($case, $config->{words});
    push @report, 'Case #'.$case->{number}.': '.$matches;
}
print join "\n", @report;


sub count_matches
{
    my ($case, $words) = @_;

    my $pattern = $case->{pattern};

    # use regexs to turn pattern into a Perl regex!
    $pattern =~ s/\(/\[/g;
    $pattern =~ s/\)/\]/g;

    return scalar grep { /^$pattern$/ } @{$words};
}


sub parse_config_file
{
    my $fh = IO::File->new(shift);

    my ($word_length, $word_count, $cases) = split / /, <$fh>;
    my $config = {};

    for (my $i=1; $i<=$word_count; $i++)
    {
        my $word = <$fh>;
        chomp $word;
        push @{$config->{words}}, $word;
    }

    for (my $i=1; $i<=$cases; $i++)
    {
        my $case = {number => $i}; # for reporting

        my $pattern = <$fh>;
        chomp $pattern;
        $case->{pattern} = $pattern;

        push @{$config->{cases}}, $case;
    }

    return $config;
}
