#!/usr/bin/env perl

use Test::More;

note "skipping a feature";
{
    # Needs its own package because perl5i is not always lexical
    package Foo1;

    use perl5i::latest -skip => ['Signatures'];

    ::ok !eval q[method foo { 42 }; 1];
    ::ok !defined &foo;
}

note "skipping autodie";
{
    # Needs its own package because perl5i is not always lexical
    package Foo2;

    use perl5i::latest -skip => ["autodie"];
    open my $fh, "/i/do/not/exist/alfkjaldjlf";
    ::pass("autodie is disabled");
}

note "unknown feature error";
{
    my $feature = 'Orbital Mind Control Lasers';
    ok !eval {
        perl5i::latest->import( -skip => [$feature] );
    };
    is $@, sprintf "Unknown feature '%s' in skip list at %s line %d.\n", $feature, $0, __LINE__-2;
}

note "unknown import parameter";
{
    ok !eval {
        perl5i::latest->import( wibble => "what" );
    };
    is $@, sprintf "Unknown parameters 'wibble => what' in import list at %s line %d.\n", $0, __LINE__-2;
}

done_testing;
