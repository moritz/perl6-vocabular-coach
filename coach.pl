use v6;

use JSON::Tiny;

sub read-dict($fn) {
    my %words;
    my $file = open $fn;
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
    return %words;
}

sub read-state($fn) {
    return () unless $fn.IO.e;
    my $contents = slurp $fn;
    my $results  = from-json($contents);
    return $results;
}

sub save-state($fn, %state) {
    my $file = open :w, "$fn.tmp";
    $file.say: to-json(%state);
    $file.close;
    run("mv -f $fn.tmp $fn");
}

my $fn = 'data/words-no-de';

my %words = read-dict($fn);
my %state = read-state("$fn.state");
my %p;

sub propability_for_count($c) {
    $c > 4 ?? 1 / $c !! 5 - $c;
}

for %words.keys -> $k {
    if %state{$k}<answers> -> @a {
        my $i = 0;
        for @a {
            last unless $_;
            $i++;
        }
        %state{$k}<good_answers> = $i;
        %state{$k}.delete('answers');
    }

    %p{$k} = propability_for_count %state{$k}<good_answers> // 0;
}

sub normalize($x) {
    $x.trans([<å ø æ Å Ø Æ ä ö ü Ä Ö Ü>]
            => [<aa oe ae Aa Oe Ae ae oe ue Ae Oe Ue>]);
}

my ($right, $wrong) = 0 xx *;
loop {
    my $sl = %p.pick;
    my $fl = %words{$sl};
    my $response = prompt("(de) $sl = (no) ");

    unless $response.defined {
        # End of input
        say '';
        say "Total: {$right + $wrong} words";
        last unless $right + $wrong;
        say "$right :-) or :-/";
        say "$wrong :-(";
        printf "%.2f%% right\n", (100 * $right / ($right + $wrong));

        %state<__meta__><right> += $right;
        %state<__meta__><wrong> += $wrong;

        save-state("$fn.state", %state);
        say "hade bra!";
        last;
    }


    if $response eq $fl || $response.subst(/^aa\s+/, '') eq $fl.subst(/^å\s+/, '') {
        say ":-)";
        ++%state{$sl}<good_answers>;
        ++$right;
    } elsif normalize($response) eq normalize($fl) {
        say ":-/    $fl";
        ++$right;
        ++%state{$sl}<good_answers>;
    } else {
        say ":-(    $fl";
        ++$wrong;
        %state{$sl}<good_answers> = 0;
    }
    if %state{$sl}<good_answers> > 4 {
        say ':-)))))';
    }
    %p{$sl} = propability_for_count %state{$sl}<good_answers>;
}


# vim: ft=perl6
