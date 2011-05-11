#!/usr/bin/perl

use perl5i::latest;
use Test::More;

# requiring perl5i is ok
require_ok "perl5i";

# using it is not
ok !eval "use perl5i";
like $@, qr/perl5i will break compatibility/;

# but -Mperl5i on the command line means -Mperl5i::latest, and it A-OK
is capture {system ($^X, '-Ilib', '-Mperl5i', '-e', q|say 'OK!'|)},
    "OK!\n", q{perl -Mperl5i -e '...' means -Mperl5i::latest};

done_testing();
