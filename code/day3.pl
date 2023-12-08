#! /usr/bin/env perl -w
use v5.38.1;
use DDP;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'    => \my $prd,
    'part:1' => \my $part,
);
$part //= 1;
say "Part: $part";
my $day = 3;
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";

my $input = $prd ? $real : $sample;

if ($part == 1) {
    my $total = 0;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    chomp(my @schematic = <$in>);
    close($in);

    my $cnt = 0;
    for my $y (0 .. $#schematic) {
        my $line = $schematic[$y];
        my $lastr = 0;
        while ($line =~ m/([0-9]+)/g) {
            my $pn = $1;
            my $i = index($line, $pn, $lastr);
            my $l = $i;
            my $r = $i + length($pn) - 1;
#say "$pn ($l - $r)$line";
            if ($l > 0 and substr($line, $l - 1, 1) =~ m/[^.0-9]/) {
#say "$y LEFT: ($pn)";
                $total += $pn;
                $cnt++;
            }
            if ($r < length($line) and substr($line, $r + 1, 1) =~ m/[^.0-9]/) {
#say "$y RIGHT: ($pn)";
                $total += $pn;
                $cnt++;
            }
            my $pl = $l > 0 ? $l - 1 : $l;
            my $pr = $r < length($line) ? $r + 1 : $r;
            if ($y > 0) {
                my $pline = $schematic[$y - 1];
                my $pv = substr($pline, $pl, $pr - $pl + 1);
                if ($pv =~ m/[^.0-9]/) {
#say "$y TOP: $pv ($pn/$pl - $pr)$pline";
                    $total += $pn;
                    $cnt++;
                }
            }
            if ($y < $#schematic) {
                my $nline = $schematic[$y + 1];
                my $pv = substr($nline, $pl, $pr - $pl + 1);
                if ($pv =~ m/[^.0-9]/) {
#say "$y BOTTOM: $pv ($pn/$pl - $pr)$nline";
                    $total += $pn;
                    $cnt++;
                }
            }
            $lastr = $pr;
        }
    }
    say "Total: $total ($cnt)";
}
