#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use_ok 'perl5i::1::equal';

{
    no warnings;
    *equal = *perl5i::1::equal::are_equal;
}

{
    package Number;
    use overload
        '0+' => sub { 42 },
        fallback => 1;

    sub new { bless {} }
}

{
    package String;
    use overload
        '""' => sub { 'foo' },
        fallback => 1;

    sub new { bless {} }
}

# Minimal testing of overloaded classes
ok( Number->new == 42, "Number class" );
ok( String->new eq 'foo', "String class" );

my %reftype = (
    array  => [42],
    hash   => { 4 => 2 },
    scalar => \42,
    code   => sub { 42 },
    number => 42,
    string => 'foo',
    undef  => undef,
    object => bless({}, 'Object'),
    ref    => \\'lol',
    glob   => \*STDIN,
);

{
    # Everything should be equal to itself
    ok( equal( $reftype{$_}, $reftype{$_} ), "$_ equals itself" ) for keys %reftype;

    # ... and different from everything else
    for my $reftype ( keys %reftype ) {

        my @other_refs = grep { $_ ne $reftype } keys %reftype;

        ok( !equal( $reftype{$reftype}, $reftype{$_} ), $reftype . ' not equal ' . $_ )
          for @other_refs;
    }

}

# Nested data structures
{
    my $nested1 = [ qw( foo bar baz ), { foo => { foo => $reftype{code} } } ];
    my $nested2 = [ qw( foo bar baz ), { foo => { foo => $reftype{code} } } ];
    my $nested3 = [ qw( foo baz ), { foo => { foo => $reftype{code} } } ];

    ok equal($nested1, $nested2), "Two equivalent nested data structures";
    ok !equal($nested1, $nested3), "Two non-equal nested data structures";
}

# Overloaded objects
{

    my $number = Number->new;

    ok equal($number, $number),          "OBJ== equal OBJ==";
    ok equal($number, $reftype{number}), "OBJ== equals number";

    my @other_refs = grep { $_ ne 'number' } keys %reftype;
    ok( !equal( $number, $reftype{$_} ), "OBJ== not equal to $_" ) for @other_refs;

    my $string = String->new;

    ok equal($string, $string),          qq{OBJ"" equal OBJ""};
    ok equal($string, $reftype{string}), qq{OBJ"" equal string};

    @other_refs = grep { $_ ne 'string' } keys %reftype;
    ok( !equal( $string, $reftype{$_} ), qq{OBJ"" not equal to $_} ) for @other_refs;
}

done_testing();
