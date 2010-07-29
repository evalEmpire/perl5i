#!/usr/bin/perl

use perl5i::2;
use Test::More;


# Test func
{
    func minus($this, $that) { return $this - $that }
    is minus(2, 3), -1;
}


# Test method
{
    {
        package Foo;
        use perl5i::2;

        method new ($class: %args) {
            return bless \%args, $class;
        }
        method get ($thing) {
            return unless @_;  # just to shut up warnings
            return $self->{$thing};
        }
    }

    my $obj = Foo->new( this => 42, that => 23 );
    isa_ok $obj, "Foo";
    is $obj->get("this"), 42;
    is $obj->get("wibble"), undef;

    # When we get required parameters this should use them.
    is $obj->get(), undef;
}


# Anonymous
{
    my $code = func($this, @these) {
        return $this, \@these;
    };

    is_deeply [$code->(42, 1, 2, 3)], [42, [1,2,3]];

    my $method = method($arg) {
        return $self, $arg;
    };

    is_deeply [Foo->$method(23)], ["Foo", 23];
}


# Test an anonymous function keeps the same signature
{
    my %last;
    for(1..3) {
        my $code = func($this, $that) { return "$this, $that"; };

        if( $last{code} ) {
            is $code->signature->mo->id, $last{sig}->mo->id, "same signature";
            is $code->mo->id, $last{code}->mo->id,           "same code ref";
        }

        $last{code} = $code;
        $last{sig}  = $code->signature;
    }
}


done_testing();
