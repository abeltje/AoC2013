#! /usr/bin/env perl -w
use v5.38.1;
use DDP;
use File::Basename;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'        => \my $prd,
    'part|p:1'   => \my $part,
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
    my $iseq = do { local $/; <$in> };
    close($in);
    $iseq =~ s{\n+}{,}g;
    for my $item (split(/,/, $iseq)) {
        my $hash = calc_hash($item);
        $total += $hash;
    }
    say "Total: $total";
}

sub calc_hash ($string) {
    my $current = 0;
    for my $char (split(/|/, $string)) {
        $current += ord($char);
        $current *= 17;
        $current %= 256;
    }
    return $current;
}
