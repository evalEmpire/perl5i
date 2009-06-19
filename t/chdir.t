#!/usr/bin/perl

use perl5i;
use Test::More;

{
    ok -e "t/chdir.t";

    {
        local $CWD = "t";
        ok -e "chdir.t";
    }

    ok -e "t/chdir.t";
}

{
    {
        local $CWD;
        push @CWD, 't';
        ok -e 'chdir.t';
    }
    ok -e 't/chdir.t';
}

done_testing();
