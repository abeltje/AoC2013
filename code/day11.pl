#! /usr/bin/env perl -w
use v5.38.1;
no warnings 'experimental::for_list';
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
    my @space;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@space, [ split(/|/, $line) ]);
    }
    close($in);
    my $espace = expand_universe(\@space);
    name_galaxies($espace);
say "@$_" for @$espace;
    my %galaxies;
    for my $y (0 .. $#{$espace}) {
        for my $x (0 .. $#{$espace->[$y]}) {
            if ($espace->[$y][$x] =~ m{^ ([0-9]+) $}x) {
                $galaxies{$1} = [$x, $y];
            }
        }
    }
    say "Identified @{[ 0+keys(%galaxies) ]} galaxies";
    my %distance;
    for my $source (sort keys %galaxies) {
        for my $dest (sort keys %galaxies) {
            next if $source eq $dest;
            my $key = join(";", sort ($source, $dest));
            next if exists($distance{ $key });
            $distance{ $key } = (abs($galaxies{$dest}->[0] - $galaxies{$source}->[0]) +
                abs($galaxies{$dest}->[1] - $galaxies{$source}->[1])) // 0;
#say "Calc $key ($source [$galaxies{$source}[0], $galaxies{$source}[1]] ".
#    "to $dest [$galaxies{$dest}[0], $galaxies{$dest}[1]]) $distance{$key}";
        }
    }
    say "Aantal afstanden: ", scalar(keys(%distance));
    my $total = 0;
    $total += $distance{$_} for keys(%distance);
    say "Total: $total";
}

sub expand_universe ($space) {
    my @vspace;
    for my $row (@$space) {
        push(@vspace, [ @$row ]);
        if (!grep { /^#$/ } @$row) {
            push(@vspace, [ @$row ]);
        }
    }
    my @hspace = map { [ @$_ ] } @vspace;
    my $ec = 0;
    for my $x (0 .. $#{$vspace[0]}) {
        my @column = map { $_->[$x] } @vspace;
        if (!grep { /^#$/ } @column) {
            for my $y (0 .. $#vspace) {
                if ($x > 0) {
                    $hspace[$y] = [
                        @{$hspace[$y]}[0..$x-1+$ec],
                        '.',
                        @{$vspace[$y]}[$x..$#{$vspace[$y]}]
                    ];
                }
                else {
                    $hspace[$y] = [ '.', @{ $vspace[$y] } ];
                }
            }
            $ec++;
        }
    }
    return \@hspace;
}

sub name_galaxies ($space) {
    my $name = 1;
    for my $row (@$space) {
        for my $col (@$row) {
            $col =~ s{#}{$name} and $name++;
        }
    }
}
