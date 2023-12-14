#! /usr/bin/env perl -w
use v5.38.1;
use DDP;
use File::Basename;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'        => \my $prd,
    'part|p:1'   => \my $part,
    'cycles|c=i' => \my $opt_cycles,
);
$part //= 1;
my ($day) = basename($0) =~ m/([0-9]+)/;
say "Day $day; Part: $part";
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";

my $input = $prd ? $real : $sample;

if ($part == 1) {
    my $total = 0;
    my @platform;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@platform, [ split(/|/, $line) ]);
    }
    close($in);
    tilt_north(\@platform);
    my $w = @platform;
    for my $row (@platform) {
        my $count = scalar(grep { $_ eq 'O' } @$row);
        my $weight = $w * $count;
        say join("", @$row) , " => $weight";
        $total += $weight;
        $w--;
    };

    say "Total: $total";
}
else {
    my $total = 0;
    my @platform;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@platform, [ split(/|/, $line) ]);
    }
    close($in);
    my $cycles = $opt_cycles // 1_000_000_000;

    # find the recuring patterns
    my @prev_platform; push(@prev_platform, [@$_]) for @platform;
    my @all_platforms = ([ @prev_platform ]);
    my $n = 1; my $same;
    do {
        tilt_north(\@platform);
        tilt_west(\@platform);
        tilt_south(\@platform);
        tilt_east(\@platform);
        @prev_platform = (); push(@prev_platform, [@$_]) for @platform;
        push(@all_platforms, [ @prev_platform ]);
        $same = find_same(\@all_platforms, \@platform);
        say "Same $n => @$same" if @$same;
        $n++;
    # if we have 2 recuring patterns we know offset and number of patterns
    } until @$same == 2;
    my $offset = $same->[0];
    my $modulo = $same->[1] - $same->[0];
    my $state = $offset + (($cycles - $offset) % $modulo);
    say "Using state $state";
    @platform = @{ $all_platforms[ $state ] };
    my $wpr = @platform;
    for my $row (@platform) {
        my $count = scalar(grep { $_ eq 'O' } @$row);
        my $weight = $wpr * $count;
        say join("", @$row) , " => $weight";
        $total += $weight;
        $wpr--;
    };
    say "Total ($cycles): $total";
}

sub is_stable ($prev, $cur) {
    if (@$prev == @$cur) {
        for my $y (0 .. $#{$cur}) {
            if (join("", @{$prev->[$y]}) ne join("", @{$cur->[$y]})) {
                return 0;
            }
        }
        return 1;
    }
    return 0;
}

sub find_same ($all, $cur) {
    my @same;
    for my $y (0 .. $#{$all} - 1) {
        push(@same, $y) if is_stable($all->[$y], $cur);
    }
    return \@same;
}

sub tilt_north ($platform) {
    for my $y (1 .. $#{$platform}) {
        for my $x (0 .. $#{$platform->[$y]}) {
            my $ny = $y - 1;
            while (    $ny >= 0
                   and $platform->[$ny+1][$x] eq 'O'
                   and $platform->[$ny][$x] eq '.')
            {
                $platform->[$ny][$x] = 'O';
                $platform->[$ny + 1][$x] = '.';
                $ny--;
            }
        }
    }
}

sub tilt_west ($platform) {
    for my $y (0 .. $#{$platform}) {
        for my $x (1 .. $#{$platform->[$y]}) {
            my $nx = $x - 1;
            while (    $nx >= 0
                   and $platform->[$y][$nx + 1] eq 'O'
                   and $platform->[$y][$nx] eq '.')
            {
                $platform->[$y][$nx] = 'O';
                $platform->[$y][$nx + 1] = '.';
                $nx--;
            }
        }
    }
}

sub tilt_south ($platform) {
    for (my $y = $#{$platform} - 1; $y >= 0; $y--) {
        for my $x (0 .. $#{$platform->[$y]}) {
            my $ny = $y + 1;
            while (    $ny <= $#{$platform}
                   and $platform->[$ny - 1][$x] eq 'O'
                   and $platform->[$ny][$x] eq '.')
            {
                $platform->[$ny - 1][$x] = '.';
                $platform->[$ny][$x] = 'O';
                $ny++;
            }
        }
    }
}

sub tilt_east ($platform) {
    for my $y (0 .. $#{$platform}) {
        for (my $x = $#{$platform->[$y]} + 1; $x >= 0; $x--) {
            my $nx = $x + 1;
            while (    $nx <= $#{$platform->[$y]}
                   and $platform->[$y][$nx - 1] eq 'O'
                   and $platform->[$y][$nx] eq '.')
            {
                $platform->[$y][$nx] = 'O';
                $platform->[$y][$nx - 1] = '.';
                $nx++;
            }
        }
    }
}
