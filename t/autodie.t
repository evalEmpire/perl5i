#!perl

use perl5i::latest;
use Test::More;

ok !eval { open my $fh, "hlaglaghlaghlagh"; 1 };

# Quiet "is not recognized as an internal or external command" on Windows.
# Good candidate for a perl5i method to control redirection portably.
if( $^O eq 'MSWin32' ) {
    ok !eval { system "haljlkjadlkjflajdf 2>NUL"; 1; };
} else {
    ok !eval { system "haljlkjadlkjflajdf"; 1; };
}

note "open() message formatting"; {
    ok !eval { open my $fh, "i_do_not_exist"; 1 };
    is $@->file, __FILE__;
    is $@->line, __LINE__ - 2;
    unlike $@, qr/perl5i/, "open error should not mention perl5i";

    TODO: {
        local $TODO = 'open function from autodie exception';
        is $@->function, "open";
    }
}

done_testing;
