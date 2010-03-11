#!/usr/bin/perl -T

use perl5i::latest;
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
# Would be nice if we could un/taint the contents, but that's not
# possible due to how Taint::Util works and its not worth fixing.
{
    my $foo = \42;
    ok !$foo->is_tainted;

    $foo->untaint;  # does nothing
    ok !$foo->is_tainted;
    ok !tainted(\$foo);  # just to be sure.

    throws_ok { $foo->taint; } qr/^Only scalars can normally be made tainted/;
    ok !$foo->is_tainted;
    ok !tainted(\$foo);  # just to be sure.
}


# A regular hash cannot be tainted
{
    my %foo;
    ok !%foo->mo->is_tainted;

    %foo->mo->untaint;  # does nothing
    ok !%foo->mo->is_tainted;
    ok !tainted(\%foo);  # just to be sure.

    throws_ok { %foo->mo->taint; } qr/^Only scalars can normally be made tainted/;
    ok !%foo->mo->is_tainted;
    ok !tainted(\%foo);  # just to be sure.
}


# A blessed hash ref object cannot be tainted
{
    my $obj = bless {}, "Foo";
    ok !$obj->mo->is_tainted;

    $obj->mo->untaint;  # does nothing
    ok !$obj->mo->is_tainted;

    throws_ok { $obj->mo->taint; } qr/^Only scalars can normally be made tainted/;
    ok !$obj->mo->is_tainted;
    ok !tainted($obj);  # just to be sure.
}


# A blessed scalar ref object cannot be untainted... though we could.
{
    my $thing = 42;
    my $obj = bless \$thing, "Foo";
    ok !$obj->mo->is_tainted;

    $obj->mo->untaint;  # does nothing
    ok !$obj->mo->is_tainted;

    throws_ok { $obj->mo->taint; } qr/^Only scalars can normally be made tainted/;
    ok !$obj->mo->is_tainted;
    ok !tainted($obj);  # just to be sure.
}


# How about a string overloaded object?
# Since its stringified value is what's important to tainting,
# we should check that.  But there's no way to reliably taint or untaint it.
{
    package Bar;
    use Test::More;
    use Test::Exception;

    use overload q[""] => sub { return ${$_[0]} }, fallback => 1;

    # Try it when its overloaded and tainted
    {
        my $thing = $^X;
        my $obj = bless \$thing, "Bar";
        is $obj, $^X;

        ok $obj->mo->is_tainted;
        ok ::tainted("$obj");

        throws_ok { $obj->mo->untaint; } qr/^Tainted overloaded objects cannot normally be untainted/;
        ok $obj->mo->taint;  # this is cool, its already tainted.
    }

    # Overloaded and not tainted
    {
        my $thing = "wibble";
        my $obj = bless \$thing, "Bar";
        is $obj, $thing;

        ok !$obj->mo->is_tainted;
        ok !::tainted("$obj");

        ok $obj->mo->untaint;  # this is cool, its already untainted.
        throws_ok { $obj->mo->taint; } qr/^Untainted overloaded objects cannot normally be made tainted/;
    }
}


# DateTime is notoriously picky about its overloading
# In particular $date+0, the usual way to numify, will die.
{
    require DateTime;
    my $date = DateTime->now;

    ok !$date->mo->is_tainted;
}

done_testing();
