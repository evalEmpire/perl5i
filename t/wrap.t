#!/usr/bin/perl
use perl5i;
use Test::More;

foreach my $word ("hello", "goodbye!") {
    foreach my $separator ("\n", ' - ', ' || ') {
        test_wrap($word, $separator);
    }
};

done_testing();

sub test_wrap {
    my ($word, $sep) = @_;
    my $txt  = ($word . ' ') x 14;

    is num_lines($txt),       1, "Unmodified string is one line long";
    is num_lines($txt->wrap), 2, "Default wrapping gives two lines";

    is num_lines($txt->wrap(width => length($word) + 1)), 14, "One word per line";
    is num_lines($txt->wrap(width => length($txt)  + 1)),  1, "Excessive wrap length";

    is $txt->wrap(width => 0),  $txt, "Zero wrap length";
    is $txt->wrap(width => -1), $txt, "Negative wrap length";
}

sub num_lines {
    my ($txt, $separator) = @_;
    $separator //= "\n";

    my @lines = split($separator, $txt);

    return scalar @lines;
}
