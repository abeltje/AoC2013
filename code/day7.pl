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

my (@cards, %cv, @type, %tv);
if ($part == 1) {
    @cards = qw< A K Q J T 9 8 7 6 5 4 3 2 >;
    my $i = 1; %cv = map { ($_ => $i++) } reverse(@cards);
    @type = qw< 5 4 F 3 T 2 H >;
    $i = 1; %tv = map { ($_ => $i++) } reverse(@type);

    my @games;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@games, [ split(" ", $line) ]);
    }
    close($in);
    for my $game (@games) {
        my $t = gametype($game->[0]);
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
else {
    @cards = qw< A K Q T 9 8 7 6 5 4 3 2 J >;
    my $i = 1; %cv = map { ($_ => $i++) } reverse(@cards);
    @type = qw< 5 4 F 3 T 2 H >;
    $i = 1; %tv = map { ($_ => $i++) } reverse(@type);

    my @games;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    while (my $line = <$in>) {
        chomp($line);
        push(@games, [ split(" ", $line) ]);
    }
    close($in);

    for my $game (@games) {
        my $t = best_gametype($game->[0]);
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

sub gametype ($hand) {
    my %gt;
    $gt{$_}++ for split(/|/, $hand);

    my $t;
    if (keys(%gt) == 1) {
        $t = '5';
    }
    elsif (keys(%gt) == 5) {
        $t = 'H';
    }
    elsif (grep { m/^4$/ } values(%gt)) {
        $t = '4';
    }
    elsif (grep { m/^3$/ } values(%gt)) {
        $t = (grep { m/^2$/ } values(%gt)) ? 'F' : '3';
    }
    elsif (my $cnt = grep { m/^2$/ } values(%gt)) {
        $t = $cnt > 1 ? 'T' : '2';
    }
    return $t;
}

sub best_gametype ($hand) {
    return gametype($hand) unless $hand =~ m/J/;
    my $best = 'H'; my $card = 'A';
    for my $subst (@cards[0..$#cards-1]) {
        (my $newhand = $hand) =~ s{J}{$subst}g;
        my $type = gametype($newhand);
        if ($tv{$best} < $tv{$type}) {
            $best = $type;
        }
    }
    return $best;
}
