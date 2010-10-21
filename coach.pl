use v6;

my $fn = 'data/words-no-de';


my $file = open $fn;

my %words;

for $file.lines -> $l {
    my @lang = $l.split(/\s+ '-' \s+ /);
    if @lang != 2 {
        warn "Igoring line '$l'";
        next;
    }
    @lang>>.=trim;
    if %words.exists(@lang[1]) {
        warn "Ignoring second translation for @lang[1]"
             ~ "('@lang[0]' vs. '%words{@lang[1]}'";
    } else {
        %words{@lang[1]} = @lang[0];
    }
}

unless %words {
    die "No valid lines in data file found";
}

sub normalize($x) {
    $x.trans([<å ø æ Å Ø Æ ä ö ü Ä Ö Ü>]
            => [<aa oe ae Aa Oe Ae ae oe ue Ae Oe Ue>]);
}

my ($right, $wrong) = 0 xx *;
loop {
    my $sl = %words.keys.pick;
    my $fl = %words{$sl};
    my $response = prompt("(de) $sl = (no) ");
    unless $response.defined {
        say '';
        say "Total: {$right + $wrong} words";
        last unless $right + $wrong;
        say "$right :-) or :-/";
        say "$wrong :-(";
        printf "%.2f%% right\n", (100 * $right / ($right + $wrong));
        last;
    }
    if $response eq $fl {
        say ":-)";
        $right++;
    } elsif normalize($response) eq normalize($fl) {
        say ":-/    $fl";
        $right++;
    } else {
        say ":-(    $fl";
        $wrong++;
    }
}


# vim: ft=perl6
