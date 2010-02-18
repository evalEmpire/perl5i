#!/usr/bin/perl

use perl5i::latest;

use Test::More;


# Test name construction
{
    sub { 42 }->alias("foo");
    is foo(), 42;

    sub { 23 }->alias("Local::Class", "foo");
    is Local::Class->foo, 23;

    sub { 99 }->alias(qw(This Is A Little Silly));
    is This::Is::A::Little::Silly(), 99;

    sub { 123 }->alias("Some::thing");
    is Some::thing(), 123, "caller only prepended if there's no ::";

    sub { 234 }->alias("this", "that");
    is this::that(), 234,  "caller not prepended if there's more than one";

    sub bar { "wibble" }
    (\&bar)->alias("that");
    is that(), "wibble";
}


# Things other than code.
{
    our $foo;
    (\23)->alias('foo');
    is $foo, 23;

    our @bar;
    [1,2,3]->alias('bar');
    is_deeply \@bar, [1,2,3];

    our %baz;
    { foo => 23, bar => 42 }->alias('baz');
    is_deeply \%baz, { foo => 23, bar => 42 };
}


# Make sure its an alias and not a copy
{
    my @src = qw(1 2 3);
    our @dest;
    @src->alias("dest");
    is \@src, \@dest;

    my $src = \23;
    our $dest;

    $src->alias("dest");
    is $src, \$dest;
}


# Errors
{
    ok !eval {
        sub{}->alias();
        1;
    };
    like $@, qr{^\QNot enough arguments given to alias()};

    ok !eval {
        23->alias("bar");
        1;
    };
    like $@, qr{scalars cannot be aliased};
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
