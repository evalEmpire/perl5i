#!perl

use perl5i::latest;
use Test::More "no_plan";

ok !eval { open my $fh, "hlaglaghlaghlagh"; 1 };

# Quiet "is not recognized as an internal or external command" on Windows.
# Good candidate for a perl5i method to control redirection portably.
if( $^O eq 'MSWin32' ) {
    ok !eval { system "haljlkjadlkjflajdf 2>NUL"; 1; };
} else {
    ok !eval { system "haljlkjadlkjflajdf"; 1; };
}
