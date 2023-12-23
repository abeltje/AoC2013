#! /usr/bin/env perl -w
use v5.38.1;
no warnings 'experimental::for_list';
use DDP;
use File::Basename;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'        => \my $prd,
    'part|p:1'   => \my $part,
    'expand|e=i' => \my $opt_expand,
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
say "$_ => @{$galaxies{$_}}" for sort {$a <=> $b} keys(%galaxies);
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
else {
    my @space;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@space, [ split(/|/, $line) ]);
    }
    close($in);
    name_galaxies(\@space);
    my %galaxies;
    for my $y (0 .. $#space) {
        for my $x (0 .. $#{$space[$y]}) {
            if ($space[$y][$x] =~ m{^ ([0-9]+) $}x) {
                $galaxies{$1} = [$x, $y];
            }
        }
    }

    # replace a single one with $opt_exand => that is ($opt_expand - 1) more.
    # exception for $opt_expand == 1; that means add 1 extra.
    my $expand = ($opt_expand // 1) == 1 ? 1 : $opt_expand - 1;

    really_expand_universe(\@space, \%galaxies, $expand);
#say "$_ => @{$galaxies{$_}}" for sort {$a <=> $b} keys(%galaxies);

    say "Identified @{[ 0+keys(%galaxies) ]} galaxies";
    my %distance;
    for my $source (sort keys %galaxies) {
        for my $dest (sort keys %galaxies) {
            next if $source eq $dest;
            my $key = join(";", sort {$a <=> $b} ($source, $dest));
            next if exists($distance{ $key });
            $distance{ $key } = (abs($galaxies{$dest}->[0] - $galaxies{$source}->[0]) +
                abs($galaxies{$dest}->[1] - $galaxies{$source}->[1])) // 0;
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

sub really_expand_universe($space, $galaxies, $expand) {
    my %lookup_galaxy = map { (join(";", @{$galaxies->{$_}}) => $_) } keys(%$galaxies);

    for my $y (0 .. $#{$space}) {
        my $row = $space->[$y];
        if (! grep { m{^ [0-9]+ $}x } @$row) {
            my @keys = map { $lookup_galaxy{$_} } grep {
                my ($yy) = $_ =~ m{^ [0-9]+ ; ([0-9]+) $}x;
                $yy > $y;
            } keys(%lookup_galaxy);
            for my $galaxy (@keys) {
                $galaxies->{$galaxy}[1] += $expand;
            }
        }
    }
    for (my $x = $#{$space->[0]}; $x > 0; $x--) {
        my @column = map { $_->[$x] } @$space;
        if (! grep { m{^ [0-9]+ $}x } @column) {
            my @keys = map { $lookup_galaxy{$_} } grep {
                my ($xx) = $_ =~ m{^ ([0-9]+) ; [0-9]+ $}x;
                $xx > $x;
            } keys(%lookup_galaxy);
            for my $galaxy (@keys) {
                $galaxies->{$galaxy}[0] += $expand;
            }
        }
    }
}
