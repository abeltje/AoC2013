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
    my @cards = qw< A K Q J T 9 8 7 6 5 4 3 2 >;
    my $i = 1; my %cv = map { ($_ => $i++) } reverse(@cards);
    my @type = qw< 5 4 F 3 T 2 H >;
    $i = 1; my %tv = map { ($_ => $i++) } reverse(@type);

    my @games;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@games, [ split(" ", $line) ]);
    }
    close($in);
    for my $game (@games) {
        my %gt;
        $gt{$_}++ for split(/|/, $game->[0]);
        my $t = keys(%gt) == 1 ? '5'
            : keys(%gt) == 5 ? 'H'
            : '?';
        if ($t eq '?') {
            if (grep { m/^4$/ } values(%gt)) {
                $t = '4';
            }
            elsif (grep { m/^3$/ } values(%gt)) {
                $t = (grep { m/^2$/ } values(%gt)) ? 'F' : '3';
            }
            elsif (my $cnt = grep { m/^2$/ } values(%gt)) {
                $t = $cnt > 1 ? 'T' : '2';
            }
        }
        push(@$game, $t);
    }
    @games = sort {
           $tv{$b->[2]} <=> $tv{$a->[2]}
        || $cv{ substr($b->[0], 0, 1) } <=> $cv{ substr($a->[0], 0, 1) }
        || $cv{ substr($b->[0], 1, 1) } <=> $cv{ substr($a->[0], 1, 1) }
        || $cv{ substr($b->[0], 2, 1) } <=> $cv{ substr($a->[0], 2, 1) }
        || $cv{ substr($b->[0], 3, 1) } <=> $cv{ substr($a->[0], 3, 1) }
        || $cv{ substr($b->[0], 4, 1) } <=> $cv{ substr($a->[0], 4, 1) }
    } @games;
    my $total = 0;
    for my $i (0 .. $#games) {
        my $rank = @games - $i;
        $total += ($rank * $games[$i]->[1]);
        say "@{$games[$i]} ($rank)";
    }
    say "Total: $total";
}
