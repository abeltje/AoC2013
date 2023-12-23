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
    my %almanac;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    local $/ = ""; # paragraph-mode
    chomp(my $seeds = <$in>); $seeds =~ s{^seeds:\s+}{};
    my @seeds = split(" ", $seeds);
    while (my $paragraph = <$in>) {
        $paragraph =~ s{(\w+)-to-(\w+) map:\n}{};
        my ($from, $to) = ($1, $2);
        for my $mline (split(/\n/, $paragraph)) {
            my ($dstart, $sstart, $range) = split(" ", $mline);
            $almanac{ "${from}-${to}" }{ $sstart } = {
                range => $range,
                dest  => $dstart,
            };
        }
    }
    my @values = @seeds;
    my $current = 'seed';
    say "Start lookup: $current: @{[ @values ]}";
    my ($lookup) = grep { $_ =~ m{^$current-} } keys %almanac;
    while ($lookup) {
        for my $to_lookup (@values) {
            $to_lookup = lookup($almanac{$lookup}, $to_lookup);
        }
        say "$lookup: @values";
        ($current) = $lookup =~ m{^$current-(\w+)};
        ($lookup) = grep { $_ =~ m{^$current-} } keys %almanac;
    }
    my $min = $values[0];
    for my $v (@values) { $v < $min and $min = $v }
    my $total = $min;
    close($in);
    say "Total: $total";
}
else {
    my %almanac;
    open(my $in, '<', $input) or die "Cannot open($input): $!";
    local $/ = ""; # paragraph-mode
    chomp(my $seeds = <$in>); $seeds =~ s{^seeds:\s+}{};

    while (my $paragraph = <$in>) {
        $paragraph =~ s{(\w+)-to-(\w+) map:\n}{};
        my ($from, $to) = ($1, $2);
        for my $mline (split(/\n/, $paragraph)) {
            my ($dstart, $sstart, $range) = split(" ", $mline);
            $almanac{ "${from}-${to}" }{ $sstart } = {
                range => $range,
                dest  => $dstart,
            };
        }
    }
    close($in);
    my $min = $almanac{"humidity-location"}{ (sort keys %{$almanac{"humidity-location"}})[-1]}->{dest};
    my @seeds = split(" ", $seeds);
    my @locations;
    for my ($start, $count) (@seeds) {
        my $current = 'seed';
        my ($section_name) = grep { $_ =~ m{^$current-} } keys %almanac;
        say "Start lookup: $current ($section_name): $start - $count";
        my @new_ranges = ([ $start, $count ]);
        while ($section_name) {
            print "$section_name: ";
            my @temp_ranges;
            for my $range (@new_ranges) {
                push(@temp_ranges, lookup_range($almanac{$section_name}, @$range));
            }
            @new_ranges = map { [ @$_ ] } @temp_ranges;
            @temp_ranges = ( );
            ($current) = $section_name =~ m{^$current-(\w+)};
            ($section_name) = grep { $_ =~ m{^$current-} } keys %almanac;
say "@{[$section_name//'location']}: @$_" for @new_ranges;
        }
        push(@locations, map { $_->[0] } @new_ranges) if ! $section_name;
    }
    my $total = (sort {$a <=> $b} @locations)[0];
    say "Total: $total";
}


sub lookup ($map, $value) {
    for my $src (sort keys %$map) {
        if ($value >= $src and $value < ($src + $map->{$src}{range})) {
            my $offset = abs($value - $src);
            return $map->{$src}{dest} + $offset;
        }
    }
    return $value;
}

sub lookup_range ($section, $start, $count) {
    # make the section contiguous
    my @idx = sort {$a <=> $b} keys %$section;
    if ($idx[0] > 0) {
        $section->{0} = { range => $idx[0], dest => 0 };
    }
    my @list;
    for my $begin (sort {$a <=> $b} keys %$section) {
        push(@list, {min => $begin, max => $begin + $section->{$begin}{range} - 1});
    }
    # fill the gaps...!
#say "Lookup range: $start .. @{[ $start + $count ]}";
#say "$_->{min} .. $_->{max} ($section->{$_->{min}}{dest})" for @list;
    my @ranges;
    my $end = $start + $count - 1;
    for my $cur (@list) {
        if ($start >= $cur->{min} and $start <= $cur->{max}) {
            my $offset = $start - $cur->{min};
            if ($end <= $cur->{max}) {
                push(@ranges, [ $section->{$cur->{min}}{dest} + $offset, $count ]);
                last;
            }
            else {
                my $overflow = $cur->{max} - $start;
                $count -= $overflow;
                push(@ranges, [ $section->{$cur->{min}}{dest} + $offset, $overflow ]);
                $start = $cur->{max} + 1;
            }
        }
    };
    if ($start > $list[ $#list ]->{max}) {
        push(@ranges, [$start, $count]);
    }
#say "Found: @$_" for @ranges;
    return @ranges;
}
