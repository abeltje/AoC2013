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
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        my @sequence = split(" ", $line);
        my $next = next_in_sequence(\@sequence);
        say "@sequence => $next";
        $total += $next;
    }
    close($in);
    say "Total: $total";
}
else {
    my $total = 0;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        my @sequence = split(" ", $line);
        my $prev = prev_in_sequence(\@sequence);
        say "$prev => @sequence";
        $total += $prev;
    }
    close($in);
    say "Total: $total";
}

sub next_in_sequence ($sequence) {
    my @numbers = @$sequence;
    my @lod = ([@$sequence]);
    do {
        my @diffs = map { $numbers[$_ + 1] - $numbers[$_] } 0 .. $#numbers - 1;
        push(@lod, \@diffs);
        @numbers = @diffs;
    } until all_zeros(\@numbers);
    push(@{$lod[-1]}, 0);
    for (my $r = $#lod - 1; $r >= 0; $r--) {
        my $missing = $lod[$r + 1][-1] + $lod[$r][-1];
        push(@{$lod[$r]}, $missing);
    }
    return $lod[0][-1];
}

sub prev_in_sequence ($sequence) {
    my @numbers = @$sequence;
    my @lod = ([@$sequence]);
    do {
        my @diffs = map { $numbers[$_ + 1] - $numbers[$_] } 0 .. $#numbers - 1;
        push(@lod, \@diffs);
        @numbers = @diffs;
    } until all_zeros(\@numbers);
    unshift(@{$lod[-1]}, 0);
    for (my $r = $#lod - 1; $r >= 0; $r--) {
        my $missing = $lod[$r][0] - $lod[$r + 1][0];
        unshift(@{$lod[$r]}, $missing);
    }
    return $lod[0][0];
}

sub all_zeros ($list) {
    my $ok = 1;
    for my $i (@$list) { $ok &&= ($i == 0) }
    return $ok;
}
