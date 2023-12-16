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
    my @tile;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@tile, [ split(/|/, $line) ]);
    }
    close($in);
    my @energized = map { [ ('.') x @$_ ] } @tile;
    my @beams = ([ 0, 0, 'r' ]);
    my %seen = ( join(";", @{$beams[0]}) => 1 );
    my $i = 0;
    while (@beams) {
        my $beam = shift(@beams);
        my ($x, $y) = @$beam;
        $energized[$y][$x] = '#';
        my $new_beams = shine_beam($beam, $tile[$y][$x]);

        # filter existing
        $new_beams = [ grep {
            my $this_beam = join(";", @$_);
            ! grep { $this_beam eq $_ } map { join(";", @$_) } @beams;
        } @$new_beams ];

        # filter outside grid and already seen
        push(@beams, grep {
            my ($xx, $yy, $dd) = @$_;
                $yy >= 0 and $yy < @tile
            and $xx >= 0 and $xx < @{$tile[$yy]}
            and ! $seen{ join(";", $xx, $yy, $dd) }++
        } @$new_beams);
        $i++;
    }
    for my $row (@energized) {
        say join("", @$row);
        $total += scalar(grep { /^#$/ } @$row);
    }
    say "Total($i): $total";
}
else {
    my @tile;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@tile, [ split(/|/, $line) ]);
    }
    close($in);
    my @starters = (
        (map { [ $_,              0,      'd' ] } 0 .. $#{ $tile[0] }),
        (map { [ $_,              $#tile, 'u' ] } 0 .. $#{ $tile[-1] }),
        (map { [ 0,               $_,     'r' ] } 0 .. $#tile),
        (map { [ $#{ $tile[$_] }, $_,     'l' ] } 0 .. $#tile),
    );
    my %best;
    for my $start (@starters) {
        my @energized = map { [ ('.') x @$_ ] } @tile;
        my @beams = ($start);
        my %seen = ( join(";", @{$beams[0]}) => 1 );
        while (@beams) {
            my $beam = shift(@beams);
            my ($x, $y) = @$beam;
            $energized[$y][$x] = '#';
            my $new_beams = shine_beam($beam, $tile[$y][$x]);

            # filter existing
            $new_beams = [ grep {
                my $this_beam = join(";", @$_);
                ! grep { $this_beam eq $_ } map { join(";", @$_) } @beams;
            } @$new_beams ];

            # filter outside grid and already seen
            push(@beams, grep {
                my ($xx, $yy, $dd) = @$_;
                    $yy >= 0 and $yy < @tile
                and $xx >= 0 and $xx < @{$tile[$yy]}
                and ! $seen{ join(";", $xx, $yy, $dd) }++
            } @$new_beams);
        }
        my $count = 0; $count += scalar(grep { /^#$/ } @$_) for @energized;
        $best{ join(";", @$start) } = $count;
    }
    my $max = 0; my $max_starter;
    for my $starter (keys %best) {
        if ($max < $best{$starter}) {
            $max = $best{$starter};
            $max_starter = $starter;
        }
    }
    my ($mx, $my, $md) = split(/;/, $max_starter);
    $mx++; $my++;
    say "Max $max: [$mx, $my, $md]";
}

# r: x + 1; u: y - 1; l: x - 1; d: y + 1
sub shine_beam ($beam, $tile) {
    my ($x, $y, $d) = @$beam;
    if ($tile eq '.') {
        CASE: {
            local $_ = $d;
            /^r$/ and do { return [ [$x + 1, $y, $d] ] };
            /^u$/ and do { return [ [$x, $y - 1, $d] ] };
            /^l$/ and do { return [ [$x - 1, $y, $d] ] };
            /^d$/ and do { return [ [$x, $y + 1, $d] ] };
        }
    }
    elsif ($tile eq '\\') {
        CASE: {
            local $_ = $d;
            /^r$/ and do { return [ [$x, $y + 1, 'd'] ] };
            /^u$/ and do { return [ [$x - 1, $y, 'l'] ] };
            /^l$/ and do { return [ [$x, $y - 1, 'u'] ] };
            /^d$/ and do { return [ [$x + 1, $y, 'r'] ] };
        }
    }
    elsif ($tile eq '/') {
        CASE: {
            local $_ = $d;
            /^r$/ and do { return [ [$x, $y - 1, 'u'] ] };
            /^u$/ and do { return [ [$x + 1, $y, 'r'] ] };
            /^l$/ and do { return [ [$x, $y + 1, 'd'] ] };
            /^d$/ and do { return [ [$x - 1, $y, 'l'] ] };
        }
    }
    elsif ($tile eq '-') {
        CASE: {
            local $_ = $d;
            /^r$/ and do { return [ [$x + 1, $y, $d] ] };
            /^u$/ and do {
                return [
                    [ $x - 1, $y, 'l' ],
                    [ $x + 1, $y, 'r' ],
                ];
            };
            /^l$/ and do { return [ [$x - 1, $y, $d] ] };
            /^d$/ and do {
                return [
                    [ $x - 1, $y, 'l' ],
                    [ $x + 1, $y, 'r' ],
                ];
            };
        }
    }
    elsif ($tile eq '|') {
        CASE: {
            local $_ = $d;
            /^r$/ and do {
                return [
                    [ $x, $y - 1, 'u' ],
                    [ $x, $y + 1, 'd' ],
                ];
            };
            /^u$/ and do { return [ [$x, $y - 1, $d] ] };
            /^l$/ and do {
                return [
                    [ $x, $y - 1, 'u' ],
                    [ $x, $y + 1, 'd' ],
                ];
            };
            /^d$/ and do { return [ [$x, $y + 1, $d] ] };
        }
    }
}
