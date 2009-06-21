#!/usr/bin/perl

use perl5i;

use Test::More;


# Test name construction
{
    alias foo => sub { 42 };
    is foo(), 42;

    alias "Local::Class", "foo" => sub { 23 };
    is Local::Class->foo, 23;

    alias qw(This Is A Little Silly) => sub { 99 };
    is This::Is::A::Little::Silly(), 99;

    alias "Some::thing" => sub { 123 };
    is Some::thing(), 123, "caller only prepended if there's no ::";

    alias "this", "that" => sub { 234 };
    is this::that(), 234,  "caller not prepended if there's more than one";

    sub bar { "wibble" }
    alias that => \&bar;
    is that(), "wibble";
}


# Things other than code.
{
    our $foo;
    alias foo => \23;
    is $foo, 23;

    our @bar;
    alias bar => [1,2,3];
    is_deeply \@bar, [1,2,3];

    our %baz;
    alias baz => { foo => 23, bar => 42 };
    is_deeply \%baz, { foo => 23, bar => 42 };
}


# Errors
{
    ok !eval {
        alias();
        1;
    };
    like $@, qr{^\QNot enough arguments given to alias()};

    ok !eval {
        alias("foo");
        1;
    };
    like $@, qr{^\QNot enough arguments given to alias()};

    ok !eval {
        alias(sub { 42 });
        1;
    };
    like $@, qr{^\QNot enough arguments given to alias()};

    ok !eval {
        alias("foo" => "bar");
        1;
    };
    like $@, qr{^\QLast argument to alias() must be a reference};
}


# Lexical aliases
TODO: {
    todo_skip "Lexical aliasing not implemented", 2;

    my $foo = 23;
    alias my $bar => \$foo;
    is $foo, $bar;

    $foo = 99;
    is $bar, 99;
}


done_testing();
