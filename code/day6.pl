#! /usr/bin/env perl -w
use v5.38.1;
use DDP;
use File::Basename;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'    => \my $prd,
    'part:1' => \my $part,
);
$part //= 1;
my ($day) = basename($0) =~ m/([0-9]+)/;
say "Day $day; Part: $part";
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";

my $input = $prd ? $real : $sample;

if ($part == 1) {
    my $total = 1;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    (my $time = <$in>) =~ s{^Time:\s+}{};
    my @times = split(" ", $time);
    (my $dist = <$in>) =~ s{^Distance:\s+}{};
    my @dists = split(" ", $dist);
    close($in);
    # v = s; d = (t-s) * v => d = s*(t-s) > dm; st - s2 > dm; -s2 + ts -dm > 0
    # (-b +- sqrt(b2 - 4ac))/2a: (-t ± sqrt(t*t - 4*-1*-dm))/-2
    for my $i (0 .. $#times) {
        my $t = $times[$i];
        my $d = $dists[$i];
        my $s1 = (-1 * $t + sqrt($t * $t + 4*-1*$d))/-2;
        my $s2 = (-1 * $t - sqrt($t * $t + 4*-1*$d))/-2;
        $s1 = 1 + int($s1);
        $s2 = int($s2) == $s2 ? $s2 - 1 : int($s2);
        say "$t ($d) $s1 - $s2 => @{[ $s2 - $s1 + 1 ]}";
        $total *= ($s2 - $s1 + 1);
    }
    say "Total: $total";
}
