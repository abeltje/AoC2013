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
    my %field;
    my ($x, $y) = (0, 0);
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        my ($direction, $length, $colour) = $line =~ m{^ ([URDL]) \s+ ([0-9]+) \s+ \((\#[0-9a-f]{6})\) }x;
        ($x, $y) = dig_trench(\%field, $x, $y, $direction, $length);
    }
    close($in);
    my $lagoon = make_aoa(\%field);
    dig_interior($lagoon);
    my $total = 0;
    for my $row (@$lagoon) {
        my $count = scalar(grep { /^#$/ } @$row);
        $total += $count;
        say join("", @$row), " ($count)";
    }
    say "Total: $total";
}

sub dig_trench ($grid, $x, $y, $d, $l) {
    if ($d eq 'U') {
        for (1 .. $l) {
            $grid->{$y}{$x} = '#';
            $y--;
        }
    }
    elsif ($d eq 'R') {
        for (1 .. $l) {
            $grid->{$y}{$x} = '#';
            $x++;
        }
    }
    elsif ($d eq 'D') {
        for (1 .. $l) {
            $grid->{$y}{$x} = '#';
            $y++;
        }
    }
    elsif ($d eq 'L') {
        for (1 .. $l) {
            $grid->{$y}{$x} = '#';
            $x--;
        }
    }
    return ($x, $y);
}

sub make_aoa ($grid) {
    my @trenches;
    my ($miny, $maxy) = (sort {$a <=> $b} keys(%$grid))[0, -1];
    my ($minx, $maxx) = (sort {$a <=> $b} keys(%{$grid->{$miny}}))[0, -1];
    for my $y ($miny .. $maxy) {
        next if !exists($grid->{$y});
        my ($xi, $xa) = (sort {$a <=> $b} keys(%{$grid->{$y}}))[0, -1];
        $xi < $minx and $minx = $xi;
        $xa > $maxx and $maxx = $xa;
    }
    for my $y ($miny .. $maxy) {
        if (!exists($grid->{$y})) {
            push(@trenches, [ ('.') x ($maxx - $maxy) ]);
            next;
        }
        my @row;
        for my $x ($minx .. $maxx) {
            push(@row, exists($grid->{$y}{$x}) ? $grid->{$y}{$x} : '.');
        }
        push(@trenches, \@row);
    }
    return \@trenches;
}

sub dig_interior ($trenches) {
    # mark "outside" with "O"
    my @new = map { [ @$_ ] } @$trenches;
    for my $y (0 .. $#new) {
        my $rstr = join("", @{$new[$y]});
        $rstr =~ s{^ (\.+) \# }{ 'O' x length($1) . '#' }xe;
        $rstr =~ s{ \# (\.+) $}{ '#' . 'O' x length($1) }xe;
        $new[$y] = [ split(/|/, $rstr) ];
        for my $x (0 .. $#{$new[$y]}) {
            next if $new[$y][$x] ne '.';
            $new[$y][$x] = 'O' if $y == 0 or $new[$y-1][$x] eq 'O' or $new[$y][$x-1] eq 'O';
        }
        $rstr = join("", @{$new[$y]});
        $rstr =~ s{ \# (\.+) O }{ '#' . 'O' x length($1) . 'O' }xeg;
        $rstr =~ s{ O (\.+) \# }{ 'O' . 'O' x length($1) . '#' }xeg;
        $new[$y] = [ split(/|/, $rstr) ];
    }
    # upside-down
    for (my $y = $#new; $y >= 0; $y--) {
        for my $x (0 .. $#{$new[$y]}) {
            next if $new[$y][$x] ne '.';
            $new[$y][$x] = 'O' if $y == $#new or $new[$y+1][$x] eq 'O';
        }
        my $rstr = join("", @{$new[$y]});
        $rstr =~ s{ \# (\.+) O }{ '#' . 'O' x length($1) . 'O' }xeg;
        $rstr =~ s{ O (\.+) \# }{ 'O' . 'O' x length($1) . '#' }xeg;
        $new[$y] = [ split(/|/, $rstr) ];
    }
    # check the last gaps
    for my $y (0 .. $#new) {
        for my $x (0 .. $#{$new[$y]}) {
            next if $new[$y][$x] eq '#';
            $new[$y][$x] = 'O' if $y == 0 or $new[$y-1][$x] eq 'O' or $new[$y][$x-1] eq 'O';
        }
        my $rstr = join("", @{$new[$y]});
        $rstr =~ s{ \# (\.+) O }{ '#' . 'O' x length($1) . 'O' }xeg;
        $rstr =~ s{ O (\.+) \# }{ 'O' . 'O' x length($1) . '#' }xeg;
        $new[$y] = [ split(/|/, $rstr) ];
    }
    # actually dig the interior
    for my $y (0 .. $#new) {
        for my $x (0 .. $#{$new[$y]}) {
            $trenches->[$y][$x] = '#' if $new[$y][$x] eq '.';
        }
    }
}
