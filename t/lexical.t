#!/usr/bin/perl -w

# perl5i should have lexical effect, ideally

use Test::More 'no_plan';


# lexical strict
{
    use perl5i;

    ok !eval q{$foo = 42};
}

{
    ok eval q{$bar = 42};
}


# lexical File::stat?
{
    use perl5i;

    my $stat = stat("MANIFEST");
    isa_ok $stat, "File::stat";
}

TODO: {
    local $TODO = "lexical File::stat";

    my @stat = stat("MANIFEST");
    is $stat[7], -s "MANIFEST";
}
