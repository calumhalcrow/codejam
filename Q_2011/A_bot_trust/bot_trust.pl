#!/usr/bin/perl
use strict;
use warnings;

use IO::File; # from CPAN
use List::Util qw( first );

my $config_file = shift || die "Usage: perl $0 config_filename.txt";
my $config = parse_config_file($config_file) || die "couldn't load config from $config_file";


my @report;
foreach my $case (@{$config})
{
    push @report, 'Case #'.$case->{number}.': '.get_seconds_required($case);
}
print join "\n", @report;


sub get_seconds_required
{
    my $case = shift;
    my @sequence = @{$case->{sequence}};
    my $next_press = shift @sequence;

    my $time;
    my $bot_location = {O => 1, B => 1};
    my $finished;

    while (not $finished)
    {
        $time++;

        # move bot that's NOT performing next press if possible
        my $bot_not_performing_next_press = get_other_bot($next_press->{bot});

        my $next_press_other_bot
            = first { $_->{bot} eq $bot_not_performing_next_press } @sequence;

        if (defined $next_press_other_bot
            and $bot_location->{$bot_not_performing_next_press} != $next_press_other_bot->{button})
        {
            ($bot_location->{$bot_not_performing_next_press} < $next_press_other_bot->{button})
            ? $bot_location->{$bot_not_performing_next_press}++
            : $bot_location->{$bot_not_performing_next_press}--;
        }

        # if bot performing next press can press now, do so,
        # otherwise move bot
        if ($bot_location->{$next_press->{bot}} == $next_press->{button})
        {
            $next_press = shift @sequence;
            $finished = 1 if (not $next_press);
        }
        else
        {
            ($bot_location->{$next_press->{bot}} < $next_press->{button})
            ? $bot_location->{$next_press->{bot}}++
            : $bot_location->{$next_press->{bot}}--;
        }
    }

    return $time;
}


sub get_other_bot
{
    my $bot = shift;
    my %other_bot = (O => 'B', B => 'O');
    return $other_bot{$bot};
}


sub parse_config_file
{
    my $fh = IO::File->new(shift);

    my $number_of_cases = <$fh>;
    my $config = [];

    for (my $i=1; $i<=$number_of_cases; $i++)
    {
        my $case = {
            number   => $i,    # for reporting
            sequence => [],
        };

        my $full_line = <$fh>;
        chomp $full_line;

        $full_line =~ s/^\d+\s//;

        while ( $full_line =~ s/^([OB])\s(\d+)\s?// )
        {
            push @{$case->{sequence}},
                { bot => $1, button => int $2 };
        }

        push @{$config}, $case;
    }

    return $config;
}
