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
    my $pat = q[^Can't locate I/Sure/Dont/Exist\.pm in \@INC];
    $pat .= q[(?: \(you may need to install the I::Sure::Dont::Exist module\))?]; 
    $pat .= sprintf(' \(@INC contains: no thing\) at %s line %d\.$',
                    __FILE__, __LINE__-4);
    like $@, qr/$pat/;
    ok !$!, "errno didn't leak out";
}

note "Invalid module name"; {
    ok !eval { "/tmp::LOL::PWNED"->require };
    like $@, qr{^'/tmp::LOL::PWNED' is not a valid module name };
}


done_testing;
