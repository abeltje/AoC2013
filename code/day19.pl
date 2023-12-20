#! /usr/bin/env perl -w
use v5.38.1;
use DDP;
use File::Basename;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'        => \my $prd,
    'part|p:1'   => \my $part,
);
$|++;
$part //= 1;
my ($day) = basename($0) =~ m/([0-9]+)/;
say "Day $day; Part: $part";
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";

my $input = $prd ? $real : $sample;

if ($part == 1) {
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    my $rules = do { local $/ = ""; <$in> };
    my $rule = parse_rules($rules);
    my @accepted;
    while (my $line = <$in>) {
        chomp($line);
        my $part = decode_part($line);
        my $action = handle_part($rule, $part);
        push(@accepted, $part) if $action eq 'A';
    }
    close($in);
    my $total = 0;
    for my $part (@accepted) {
        $total += $part->{$_} for qw< x m a s >;
    }
    say "Total: $total";
}

sub decode_part ($str) {
    my ($to_decode) = $str =~ m/^ \{ ([^}]+) \} $/x;
    my @cats = split(/,/, $to_decode);
    my %part = map {
        my ($c, $v) = $_ =~ m{^ ([xmas]) = ([0-9]+) $}x;
        ($c => $v)
    } @cats;
    return \%part;
}

sub parse_rules ($rules) {
    my %rule;
    for my $line (split(/\n/, $rules)) {
        my ($name, $sequence) = $line =~ m{^ (\w+) \{ (.+) \} $}x;
        my @steps = map {
            my ($cmp, $next) = split(/:/, $_);
            $next = $cmp, $cmp = 1 if !$next;
            {cmp => $cmp, next => $next}
        } split(/,/, $sequence);
        $rule{$name} = \@steps;
    }
    return \%rule;
}

sub handle_part ($rules, $part) {
    my $cr = 'in';
    while ($cr !~ m{^ [AR] $}x) {
        my $rule = $rules->{$cr};
        for my $sr (@{$rule}) {
#say "RULE $cr ($sr->{cmp}/$sr->{next}): [x: $part->{x}; m: $part->{m}; a: $part->{a}; s: $part->{s}]";
            if ($sr->{cmp} eq "1") { $cr = $sr->{next}; last }
            else {
                my ($cat, $cmp, $val) = $sr->{cmp} =~ m{^ ([xmas]) ([<>]) ([0-9]+) $}x;
                if ($cmp eq '<' and $part->{$cat} < $val) {
                    $cr = $sr->{next};
                    last;
                }
                elsif ($cmp eq '>' and $part->{$cat} > $val) {
                    $cr = $sr->{next};
                    last;
                }
            }
        }
    }
    return $cr;
}
