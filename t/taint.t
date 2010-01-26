#!/usr/bin/perl -T

use perl5i;
use Test::More;
use Test::Exception;

use Scalar::Util qw(tainted);


# Check an already tainted global
{
    ok $^X->is_tainted;

    $^X->untaint;
    ok !$^X->is_tainted;
    ok !tainted($^X);

    $^X->taint;
    ok $^X->is_tainted;
    ok tainted($^X);
}


# Check a scalar
{
    my $foo = 42;
    ok !$foo->is_tainted;

    $foo->taint;
    ok $foo->is_tainted;
    ok tainted($foo);  # just to be sure.

    $foo->untaint;
    ok !$foo->is_tainted;
    ok !tainted($foo);  # just to be sure.
}


# What about a scalar ref?
# Should we check against its contents?
{
    my $foo = \42;
    ok !$foo->is_tainted;

    $foo->taint;
    ok $foo->is_tainted;
    ok tainted($foo);  # just to be sure.

    $foo->untaint;
    ok !$foo->is_tainted;
    ok !tainted($foo);  # just to be sure.
}


# A regular hash cannot be tainted
{
    my %foo;
    ok !%foo->is_tainted;

    %foo->untaint;  # does nothing
    ok !%foo->is_tainted;
    ok !tainted(\%foo);  # just to be sure.

    %foo->taint;

    TODO: {
        local $TODO = "Bug in Taint::Util prevents bare hashes and arrays from being tainted";
        ok %foo->is_tainted;
        ok tainted(\%foo);  # just to be sure.
    }
}


# A blessed hash ref object cannot be tainted
{
    my $obj = bless {}, "Foo";
    ok !$obj->is_tainted;

    $obj->untaint;  # does nothing
    ok !$obj->is_tainted;

    $obj->taint;
    ok $obj->is_tainted;
    ok tainted($obj);
}


# A blessed scalar ref object?
{
    my $thing = 42;
    my $obj = bless \$thing, "Foo";
    ok !$obj->is_tainted;

    $obj->untaint;  # does nothing
    ok !$obj->is_tainted;

    $obj->taint;
    ok $obj->is_tainted;
    ok tainted($obj);
}


# How about a string overloaded object?
# Since its stringified value is what's important to tainting,
# we should check that.  But there's no way to reliably taint or untaint it.
{
    package Bar;
    use Test::More;
    use Test::Exception;

    use overload q[""] => sub { return ${$_[0]} };

    # Try it when its overloaded and tainted
    {
        my $thing = $^X;
        my $obj = bless \$thing, "Bar";
        is $obj, $^X;

        ok $obj->is_tainted;
        ok ::tainted("$obj");

        throws_ok { $obj->untaint; } qr/^Overloaded objects cannot be untainted/;
        ok $obj->taint;  # this is cool, its already tainted.
    }

    # Overloaded and not tainted
    {
        my $thing = "wibble";
        my $obj = bless \$thing, "Bar";
        is $obj, $thing;

        ok !$obj->is_tainted;
        ok !::tainted("$obj");

        ok $obj->untaint;  # this is cool, its already untainted.
        throws_ok { $obj->taint; } qr/^Overloaded objects cannot be made tainted/;
    }
}


# DateTime is notoriously picky about its overloading
# In particular $date+0, the usual way to numify, will die.
{
    require DateTime;
    my $date = DateTime->now;

    ok !$date->is_tainted;
}

done_testing();
