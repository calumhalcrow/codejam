#!/usr/bin/perl
use strict;
use warnings;

use IO::File; # from CPAN

my $config_file = shift || die "Usage: perl $0 config_filename.txt";
my $config = parse_config_file($config_file) || die "couldn't load config from $config_file";

my @report;
foreach my $case (@{$config})
{
    push @report, 'Case #'.$case->{number}.': '.build_t9_sentence($case->{sentence});
}
print join "\n", @report;


sub build_t9_sentence
{
    my $sentence = shift;
    my @chars = split //, $sentence;
    my $t9_sentence;

    foreach my $char (@chars)
    {
        my $t9_char = build_t9_char($char);

        if (defined $t9_sentence and substr($t9_sentence, -1) eq substr($t9_char, 0, 1))
        {
            $t9_sentence .= ' ';
        }

        $t9_sentence .= $t9_char;
    }

    return $t9_sentence;
}


sub build_t9_char
{
    my $char = shift;

    my %translation_of = (
        a   => 2,
        b   => 22,
        c   => 222,
        d   => 3,
        e   => 33,
        f   => 333,
        g   => 4,
        h   => 44,
        i   => 444,
        j   => 5,
        k   => 55,
        l   => 555,
        m   => 6,
        n   => 66,
        o   => 666,
        p   => 7,
        q   => 77,
        r   => 777,
        s   => 7777,
        t   => 8,
        u   => 88,
        v   => 888,
        w   => 9,
        x   => 99,
        y   => 999,
        z   => 9999,
        ' ' => 0,
    );

    return $translation_of{$char};
}


sub parse_config_file
{
    my $fh = IO::File->new(shift);

    my $number_of_cases = <$fh>;
    my $config = [];

    for (my $j=1; $j<=$number_of_cases; $j++)
    {
        my $case = {number => $j}; # for reporting

        $case->{sentence} = <$fh>;
        chomp $case->{sentence};

        push @{$config}, $case;
    }

    return $config;
}
