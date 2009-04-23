#!/usr/bin/perl -w

# perl5i should have lexical effect, ideally

use Test::More 'no_plan';

# use perl5i in a narrow lexical scope.
# It shouldn't effect the rest of the program.
{ use perl5i }


# lexical strict
{
    ok eval q{$bar = 42};
}


# lexical File::stat?
TODO: {
    local $TODO = "lexical File::stat";

    my @stat = stat("MANIFEST");
    is $stat[7], -s "MANIFEST";
}


# lexical autodie?
{
    ok eval { open my $fh, "dlkfjal;kdj"; 1 } or diag $@;
}
