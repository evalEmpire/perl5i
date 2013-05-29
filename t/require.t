#!perl

use perl5i::latest;
use Test::More;

note "Successful require"; {
    local $!;
    local $@ = "hubba bubba";

    is "Text::ParseWords"->require, "Text::ParseWords";
    ok !$!, "errno didn't leak out";
    is $@, "hubba bubba", '$@ not overwritten';

    ok $INC{"Text/ParseWords.pm"}, "require";
    ok !defined &shellwords,        "nothing imported";

    "Text::ParseWords"->require->import;
    ok defined &shellwords,         "  default import";
}


note "Module doesn't exist"; {
    local $!;
    local @INC = qw(no thing);
    ok !eval { "I::Sure::Dont::Exist"->require; };
    like $@, qr[^Can't locate I/Sure/Dont/Exist\.pm in \@INC.*\(\@INC contains: no thing\) at ];
    ok !$!, "errno didn't leak out";
}


note "Invalid module name"; {
    ok !eval { "/tmp::LOL::PWNED"->require };
    like $@, qr{^'/tmp::LOL::PWNED' is not a valid module name };
}


done_testing;
