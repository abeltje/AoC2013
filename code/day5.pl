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
    my %almanac;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    local $/ = ""; # paragraph-mode
    chomp(my $seeds = <$in>); $seeds =~ s{^seeds:\s+}{};
    my @seeds = split(" ", $seeds);
    while (my $paragraph = <$in>) {
        $paragraph =~ s{(\w+)-to-(\w+) map:\n}{};
        my ($from, $to) = ($1, $2);
        for my $mline (split(/\n/, $paragraph)) {
            my ($dstart, $sstart, $range) = split(" ", $mline);
            $almanac{ "${from}-${to}" }{ $sstart } = {
                range => $range,
                dest  => $dstart,
            };
        }
    }
    my @values = @seeds;
    my $current = 'seed';
    say "Start lookup: $current: @{[ @values ]}";
    my ($lookup) = grep { $_ =~ m{^$current-} } keys %almanac;
    while ($lookup) {
        for my $to_lookup (@values) {
            $to_lookup = lookup($almanac{$lookup}, $to_lookup);
        }
        say "$lookup: @values";
        ($current) = $lookup =~ m{^$current-(\w+)};
        ($lookup) = grep { $_ =~ m{^$current-} } keys %almanac;
    }
    my $min = $values[0];
    for my $v (@values) { $v < $min and $min = $v }
    my $total = $min;
    close($in);
    say "Total: $total";
}


sub lookup ($map, $value) {
    for my $src (sort keys %$map) {
        if ($value >= $src and $value < ($src + $map->{$src}{range})) {
            my $offset = abs($value - $src);
say "$value ($src) => $map->{$src}{dest} + $offset";
            return $map->{$src}{dest} + $offset;
        }
    }
    return $value;
}
