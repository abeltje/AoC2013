#! /usr/bin/env perl -w
use v5.38.1;
use DDP;
use File::Basename;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'      => \my $prd,
    'part|p:1' => \my $part,
);
$part //= 1;
my ($day) = basename($0) =~ m/([0-9]+)/;
say "Day $day; Part: $part";
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";

my $input = $prd ? $real : $sample;

if ($part == 1) {
    my $total = 0;
    my @platform;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@platform, [ split(/|/, $line) ]);
    }
    close($in);
    tilt_north(\@platform);
    my $w = @platform;
    for my $row (@platform) {
        my $count = scalar(grep { $_ eq 'O' } @$row);
        my $weight = $w * $count;
        say join("", @$row) , " => $weight";
        $total += $weight;
        $w--;
    };

    say "Total: $total";
}

sub tilt_north ($platform) {
    for my $y (1 .. $#{$platform}) {
        for my $x (0 .. $#{$platform->[$y]}) {
            my $ny = $y - 1;
            while (    $ny >= 0
                   and $platform->[$ny+1][$x] eq 'O'
                   and $platform->[$ny][$x] eq '.')
            {
                $platform->[$ny][$x] = 'O';
                $platform->[$ny + 1][$x] = '.';
                $ny--;
            }
        }
    }
}

