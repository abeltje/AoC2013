#! /usr/bin/env perl -w
use v5.38.1;
use DDP;
use File::Basename;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'       => \my $prd,
    'part|p:1'  => \my $part,
    'input|i=s' => \my $infile,
);
$part //= 1;
my ($day) = basename($0) =~ m/([0-9]+)/;
say "Day $day; Part: $part";
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";

my $input = $infile ? $infile : $prd ? $real : $sample;

my %moves = (
    'S' => {
        up => [qw< | F 7 >],
        rt => [qw< - 7 J >],
        dn => [qw< | L J >],
        lt => [qw< - L F >],
    },
    'J' => {
        up => [qw< | F 7 >],
        lt => [qw< - L F >],
    },
    'L' => {
        up => [qw< | F 7 >],
        rt => [qw< - 7 J >],
    },
    'F' => {
        rt => [qw< - 7 J >],
        dn => [qw< | L J >],
    },
    '7' => {
        dn => [qw< | L J >],
        lt => [qw< - L F >],
    },
    '|' => {
        up => [qw< | F 7 >],
        dn => [qw< | L J >],
    },
    '-' => {
        rt => [qw< - 7 J >],
        lt => [qw< - L F >],
    },
);

if ($part == 1) {
    my $total = 0;
    my @tiles;
    my $y = 0;
    my ($sx, $sy);
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        $tiles[$y] = [ split(/|/, $line) ];
        if ((my $i = index($line, 'S')) >= 0) {
            $sx = $i;
            $sy = $y;
        }
        $y++;
    }
    close($in);
    say "Start at ($sy, $sx) $tiles[$sy][$sx]";
    my @move = ( [$tiles[$sy][$sx], $sy, $sx ] );
    my $d = 0;
    my %seen; # = ( "$sy;$sx" => 1 );
    do {
        my @new_moves = map { next_move(\@tiles, @$_) } @move;
        @move = grep {
            ! $seen{ "$_->[1];$_->[2]" }++
        } @new_moves;
#say "$d: @$_" for @move;
        $d++;
    } until !@move;
    $d--;
    say "Total: $d";
}

sub next_move ($tiles, $pipe, $y, $x) {
    my @moves;
    for my $dir (keys %{$moves{$pipe}}) {
        if ($dir eq 'up' and $y > 0) {
            my $ny = $y - 1;
            if (grep { $tiles->[$ny][$x] eq $_ } @{$moves{$pipe}{$dir}}) {
                push(@moves, [ $tiles->[$ny][$x], $ny, $x ]);
            }
        }
        if ($dir eq 'rt' and $x < $#{$tiles->[$y]}) {
            my $nx = $x + 1;
            if (grep { $tiles->[$y][$nx] eq $_ } @{$moves{$pipe}{$dir}}) {
                push(@moves, [ $tiles->[$y][$nx], $y, $nx ]);
            }
        }
        if ($dir eq 'dn' and $y < $#{$tiles}) {
            my $ny = $y + 1;
            if (grep { $tiles->[$ny][$x] eq $_ } @{$moves{$pipe}{$dir}}) {
                push(@moves, [ $tiles->[$ny][$x], $ny, $x ]);
            }
        }
        if ($dir eq 'lt' and $x > 0) {
            my $nx = $x - 1;
            if (grep { $tiles->[$y][$nx] eq $_ } @{$moves{$pipe}{$dir}}) {
                push(@moves, [ $tiles->[$y][$nx], $y, $nx ]);
            }
        }
    }
    return @moves;
}
