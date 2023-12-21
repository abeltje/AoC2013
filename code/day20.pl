#! /usr/bin/env perl -w
use v5.38.1;
use DDP;
use File::Basename;
use Getopt::Long qw< :config pass_through >;
GetOptions(
    'prd'        => \my $prd,
    'part|p:1'   => \my $part,
    'input|i=s'  => \my $infile,
    'count|c=i'  => \my $count,
);
$|++;
$part //= 1;
my ($day) = basename($0) =~ m/([0-9]+)/;
say "Day $day; Part: $part";
my $sample = "code/sample$day-$part";
my $real = "data/day$day-$part";
$count //= 1;

my $input = $infile ? $infile : $prd ? $real : $sample;

if ($part == 1) {
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    my %modules = ( button => {outputs => ['broadcaster']} );
    my %inputs;
    while (my $line = <$in>) {
        chomp($line);
        my ($type, $name, $outputs) = $line =~ m{^ ([%&]?) (\w+) \s+ -> \s+ (.+) $}x;
        $type ||= 'b';
        $modules{$name} = {
            name    => $name,
            type    => $type,
            outputs => [ split(/\s*,\s*/, $outputs)  ],
            ($type eq '%' ? (state => 'off') : ()),
        };
        for my $output (@{$modules{$name}{outputs}}) {
            push(@{$inputs{$output}}, $name);
        }
    }
    close($in);
    for my $input (keys %inputs) {
        next unless $modules{$input}{type}//'' eq '&';
        $modules{$input}{inputs}{$_} = 'L' for @{ $inputs{$input} };
    }
    my $low = 0; my $high = 0;
    for (1 .. $count) {
        my $thing = [ ['broadcaster', 'L', 'button'] ];
        while (@$thing > 0) {
            my $this = shift(@{ $thing });
            $_->[1] eq 'L' and $low++  for $this;
            $_->[1] eq 'H' and $high++ for $this;
            my $new_signals = handle_signal(\%modules, @$this);
            push(@$thing, @$new_signals);
        }
    }
    say "Total: @{[ $high * $low ]} => High = $high; Low = $low";
}

sub handle_signal ($modules, $name, $signal, $from) {
    my $module = $modules->{$name};
    my $return;
    if (!exists($module->{type})) {
        $module->{state} = $signal;
        $return = [ ];
    }
    elsif ($module->{type} eq 'b') { # broadcaster
        $return = [ map { [$_, $signal, $name] } @{$module->{outputs}} ];
    }
    elsif ($module->{type} eq '%' and $signal eq 'L') { # flip-flop
        if ($module->{state} eq 'off') {
            $module->{state} = 'on';
            $return = [ map { [$_, 'H', $name] } @{$module->{outputs}} ];
        }
        else {
            $module->{state} = 'off';
            $return = [ map { [$_, 'L', $name] } @{$module->{outputs}} ];
        }
    }
    elsif ($module->{type} eq '&') { # conjunction
        $module->{inputs}{$from} = $signal;
        my $all_high = 1;
        for my $input (keys %{$module->{inputs}}) { $all_high &&= ($module->{inputs}{$input} eq 'H') }
        if ($all_high) {
            $return = [ map { [$_, 'L', $name] } @{$module->{outputs}} ];
        }
        else {
            $return = [ map { [$_, 'H', $name] } @{$module->{outputs}} ];
        }
    }
say "$from ($signal) $name: @{[reverse(@$_)]}" for @$return;
    return $return;
}
