#!/usr/bin/perl

use perl5i::latest;

use Test::More;

{
    package Foo;

    our %hash;
    our @array;
    our $scalar;
    sub function {}

    our %thing = ( foo => 42 );
    sub thing { return 23 }
}

note "symbol_table"; {
    my $table = "Foo"->mc->symbol_table;

    is_deeply [$table->keys->sort],
              [sort qw(hash array scalar function thing)],
              "symbol_table";

    my $glob = $table->{thing};

    is_deeply *{$glob}{HASH}, { foo => 42 },    "glob contains a hash";

    my $code = *{$glob}{CODE};
    is $code->(), 23,                           "glob contains a code ref";

    ok !*{$glob}{ARRAY},                        "glob does not contain an array";
}

done_testing;
