use v6;

my $fn = 'data/words-no-de';


my $file = open $fn;

my @words;

for $file.lines -> $l {
    my @lang = $l.split(/\s+ '-' \s+ /);
    if @lang != 2 {
        warn "Igoring line '$l'";
        next;
    }
    @lang>>.=trim;
    @words.push: @lang[0] => @lang[1];
}

unless @words {
    die "No valid lines in data file found";
}

sub normalize($x) {
    $x.trans([<å ø æ Å Ø Æ ä ö ü Ä Ö Ü>]
            => [<aa oe ae Aa Oe Ae ae oe ue Ae Oe Ue>]);
}

loop {
    my $pair = @words.pick;
    my ($fl, $sl) = $pair.kv;
    my $response = prompt("(de) $sl = (no) ");
    if $response eq $fl {
        say ":-)";
    } elsif normalize($response) eq normalize($fl) {
        say ":-/    $fl";
    } else {
        say ":-(    $fl";

    }
}


# vim: ft=perl6
