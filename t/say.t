#!/usr/bin/perl

use perl5i::latest;

use Test::More;
use Test::Output;

{
    my %hash = (foo => 23, bar => 42);
    my $as_string = join " ", map { "$_ => $hash{$_}" } keys %hash;
    stdout_is { %hash->say   } "$as_string\n", "%hash->say";
    stdout_is { %hash->print } $as_string,     "%hash->print";
}

done_testing();
