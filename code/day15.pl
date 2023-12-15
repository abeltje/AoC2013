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
else {
    my $total = 0;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    my $iseq = do { local $/; <$in> };
    close($in);
    $iseq =~ s{\n+}{,}g;
    my @box = map { [] } 0 .. 255;
    for my $item (split(/,/, $iseq)) {
        my ($label) = $item =~ m{^ ([^=-]+) [=-] }x;
        my $hash = calc_hash($label);
        if ($item =~ m{^ \Q$label\E = ([0-9]+) $}x) {
            replace_lens($box[$hash], $label, $1);
        }
        elsif ($item =~ m{^ \Q$label\E - $}x) {
            remove_lens($box[$hash], $label);
        }
    }
    for my $i (0 .. $#box) {
        next unless @{$box[$i]};
        for my $slot (0 .. $#{$box[$i]}) {
            my $fp = ($i + 1) * ($slot + 1) * $box[$i]->[$slot][1];
            $total += $fp;
        }
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

sub replace_lens ($box, $label, $fl) {
    for my $slot (@$box) {
        if ($slot->[0] eq $label) {
            $slot->[1] = $fl;
            return;
        }
    }
    push(@$box, [$label, $fl]);
}

sub remove_lens ($box, $label) {
    @$box = grep { $_->[0] ne $label } @$box;
}
