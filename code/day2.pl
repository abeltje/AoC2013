#! /usr/bin/env perl -w
use v5.38.1;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'    => \my $prd,
    'part:1' => \my $part,
);
$part //= 1;
say "Part: $part";
my $day = 2;
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";

my $input = $prd ? $real : $sample;

if ($part == 1) {
    my $colours = join("|", qw<blue red green>);
    my %max_cubes = (red => 12, green => 13, blue => 14);
    my $total = 0;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        $line =~ s{^Game ([0-9]+):\s+}{};
        my $id = $1;
        my @goes = split(/;\s*/, $line);
        my $ok = 1;
        for my $go (@goes) {
            my @parts = split(/,\s*/, $go);
            for my $prt (@parts) {
                my ($n, $c) = $prt =~ m{([0-9]+) ($colours)};
                $ok &&= $n <= $max_cubes{$c};
            }
        }
        say "$id: $line" if $ok;
        $total += $id if $ok;
    }
    close($in);
    say "Total: $total";
}
else {
    my $colours = join("|", qw<blue red green>);
    my $total = 0;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        my %min_cubes = (red => 0, green => 0, blue => 0);
        chomp($line);
        $line =~ s{^Game ([0-9]+):\s+}{};
        my @goes = split(/;\s*/, $line);
        for my $go (@goes) {
            my @parts = split(/,\s*/, $go);
            for my $prt (@parts) {
                my ($n, $c) = $prt =~ m{([0-9]+) ($colours)};
                $min_cubes{$c} = $n if $min_cubes{$c} < $n;
            }
        }
        my $power = $min_cubes{red} * $min_cubes{green} * $min_cubes{blue};
        $total += $power;
    }
    close($in);
    say "Total: $total";
}

