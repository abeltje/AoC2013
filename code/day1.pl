#! /usr/bin/env perl -w
use v5.38.1;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'    => \my $prd,
    'part:1' => \my $part,
);
$part //= 1;
say "Part: $part";
my $day = 1;
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";

my $input = $prd ? $real : $sample;

if ($part == 1) {
    my $total = 0;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        my ($first) = $line =~ m{^.*?([0-9])};
        my ($last)  = $line =~ m{([0-9])[^0-9]*$};
        $total += 0 + "$first$last";
        say "$first$last => $line";
    }
    close($in);
    say "Total: $total";
}
else {
    my @digits = qw< one two three four five six seven eight nine >;
    my $i = 1;
    my %value = map { ($_ => $i++) } @digits;
    $i = 1; $value{str_reverse($_)} = $i++ for @digits;
    $value{$_} = $_ for 1..9;
    my $fwd = join("|", @digits);
    my $bwd = join("|", map { str_reverse($_) } @digits);

    my $total = 0;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        my ($first) = $line =~ m{^.*?([0-9]|$fwd)};
        my ($last)  = str_reverse($line) =~ m{^.*?([0-9]|$bwd)};
        $total += 0 + "$value{$first}$value{$last}";
        say "($first, $last) $value{$first}$value{$last} => $line";
    }
    close($in);
    say "Total: $total";
}


sub str_reverse ($string) {
    return scalar(reverse($string));
}
