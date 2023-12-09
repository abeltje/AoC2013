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

my (@cards, %cv, @type, %tv);
if ($part == 1) {
    my %network;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    chomp(my $instructions = do { local $/ = ""; <$in> });
    while (my $line = <$in>) {
        my ($n, $l, $r) = $line =~ m{^([A-Z]{3}) = \(([A-Z]{3}), ([A-Z]{3})\)};
        $network{$n} = { L => $l, R => $r };
    }
    close($in);
    my $step = 0; my $node = 'AAA';
    while ($node ne 'ZZZ') {
        my $idx = $step % (length($instructions) - 1);
        my $direction = substr($instructions, $idx, 1);
say "$step ($idx): $node => $direction";
        $node = $network{$node}->{$direction};
        $step++;
    }
    say "Total: $step";
}
else {
    say "Niet gedaan nog";
}
