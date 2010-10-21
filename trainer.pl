use v6;

my $fn = 'data/words-no-de';


my $file = open $fn;

say $file.get;
my @words;

for $file.lines -> $l {
    my @lang = $l.split(/\s+ '-' \s+ /);
    if @lang != 2 {
        warn "Igoring line '$l'";
        next;
    }
    @lang[$_].=trim for ^2;
    @words.push: @lang[0] => @lang[1];
}

unless @words {
    die "No valid lines in data file found";

}

loop {
    my $pair = @words.pick;
    my ($fl, $sl) = $pair.kv;
    my $response = prompt("(de) $sl = (no) ");
    if $response eq $fl {
        say ":-)";
    } else {
        say ":-(    $fl";

    }

}


# vim: ft=perl6
