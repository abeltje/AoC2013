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
    my $total = 0;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        $line =~ s{^Card\s+([0-9]+):\s+}{};
        my $cardnr = $1;
        my ($winning, $have) = split(/\s+\|\s+/, $line);
        my %wins = map { ($_ => undef) } split(" ", $winning);
        my @havs = split(" ", $have);
        my $keys = scalar(keys(%wins));
        exists($wins{$_}) and delete($wins{$_}) for @havs;
        my $left = scalar(keys(%wins));
        my $pow = $keys - $left;
say "$keys - $left @{[ $pow ? (2 ** ($pow - 1)) : 0 ]}";
        $total += $pow ? (2 ** ($pow - 1)) : 0;
    }
    close($in);
    say "Total: $total";
}
else {
    my $total = 0;
    my %copy;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        $line =~ s{^Card\s+([0-9]+):\s+}{};
        my $cardnr = $1;
        my ($winning, $have) = split(/\s+\|\s+/, $line);
        my %wins = map { ($_ => undef) } split(" ", $winning);
        my @havs = split(" ", $have);
        my $keys = scalar(keys(%wins));
        exists($wins{$_}) and delete($wins{$_}) for @havs;
        my $copies = $keys - keys(%wins);
say "$cardnr: $copies";
        for my $coffs (1 .. $copies) {
            $copy{ $cardnr + $coffs }++;
        }
        if (exists($copy{$cardnr})) {
            for my $n (1 .. $copy{$cardnr}) {
                for my $coffs (1 .. $copies) {
                    $copy{ $cardnr + $coffs }++;
                }
            }
        }

        $total += 1;
    }
    close($in);
    for my $cardnr (keys(%copy)) {
        $total += $copy{$cardnr};
    }
    say "Total: $total";
}
