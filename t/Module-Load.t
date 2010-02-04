#!perl

use perl5i::latest;
use Test::More;

"Text::ParseWords"->load("shellwords");
ok $INC{"Text/ParseWords.pm"}, "load()";
ok defined &shellwords,        "  explicit import honored";

ok !defined &load,              "perl5i does not export load()";

done_testing;
