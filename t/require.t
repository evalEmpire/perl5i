#!perl

use perl5i::latest;
use Test::More;

# Test successful require
{
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

# And a failed on
{
    local $!;
    local @INC = qw(no thing);
    ok !eval { "I::Sure::Dont::Exist"->require; };
    is $@,
      sprintf(qq[Can't locate %s in \@INC (\@INC contains: %s) at %s line %d.\n],
              "I/Sure/Dont/Exist.pm", "no thing", __FILE__, __LINE__-3);
    ok !$!, "errno didn't leak out";
}

done_testing;
