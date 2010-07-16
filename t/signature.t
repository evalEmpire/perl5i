#!/usr/bin/perl

use perl5i::latest;
use Test::More;

# Empty signature
{
    my $sig = perl5i::2::Signature->new( signature => "" );
    isa_ok $sig, "perl5i::2::Signature::None";
    is $sig->num_params, 0;
    is_deeply $sig->params, [];
    is $sig, "";
    ok $sig;
    is $sig->invocant, '';
    ok !$sig->is_method;
}


# Empty signature with spaces
{
    my $sig = perl5i::2::Signature->new( signature => "  " );
    isa_ok $sig, "perl5i::2::Signature::None";
    is $sig->num_params, 0;
    is_deeply $sig->params, [];
    is $sig, "  ";
    is $sig->invocant, '';
    ok !$sig->is_method;
}


# Empty signature on a method
{
    my $sig = perl5i::2::Signature->new( signature => "  ", is_method => 1 );
    isa_ok $sig, "perl5i::2::Signature::None";
    is $sig->num_params, 0;
    is_deeply $sig->params, [];
    is $sig, "  ";
    is $sig->invocant, '$self';
    ok $sig->is_method;
}


# One arg signature
{
    my $sig = perl5i::2::Signature->new( signature => '$foo' );
    isa_ok $sig, "perl5i::2::Signature";
    is $sig->num_params, 1;
    is_deeply $sig->params, ['$foo'];
    is $sig, '$foo';
    isa_ok $sig, "perl5i::2::Signature::Real";
    is $sig->invocant, '';
    ok !$sig->is_method;
}


# Two arg signature
{
    my $sig = perl5i::2::Signature->new( signature => '$foo , @bar' );
    is $sig->num_params, 2;
    is_deeply $sig->params, ['$foo', '@bar'];
    is $sig, '$foo , @bar';
    is $sig->invocant, '';
    ok !$sig->is_method;
}


# With leading and trailing spaces
{
    my $sig = perl5i::2::Signature->new( signature => ' $foo , @bar ' );
    is $sig->num_params, 2;
    is_deeply $sig->params, ['$foo', '@bar'];
    is $sig, ' $foo , @bar ';  # an exact reproduction
    is $sig->invocant, '';
    ok !$sig->is_method;
}


# With an invocant
{
    my $sig = perl5i::2::Signature->new( signature => '$class: @bar', is_method => 1 );
    is $sig->num_params, 1;
    is_deeply $sig->params, ['@bar'];
    is $sig, '$class: @bar';
    is $sig->invocant, '$class';
    ok $sig->is_method;
}


# Method, implied invocant
{
    my $sig = perl5i::2::Signature->new( signature => '@bar', is_method => 1 );
    is $sig->num_params, 1;
    is_deeply $sig->params, ['@bar'];
    is $sig, '@bar';
    is $sig->invocant, '$self';
    ok $sig->is_method;
}


# Try setting a signature on a code reference
{
    my $sig = perl5i::2::Signature->new( signature => '$arg', is_method => 1 );
    my $echo = sub {
        my $self = shift;
        my($arg) = @_;

        return $arg;
    };

    $echo->__set_signature($sig);
    is $echo->signature, $sig;
}


# And now bring it all together
{
    def echo($arg) {
       return $arg; 
    }

    my $sig = (\&echo)->signature;
    isa_ok $sig, "perl5i::2::Signature";
    ok $sig, '$arg';
    is $sig->num_params, 1;
}


# An anon code ref
{
    my $echo = def ($arg) {
    };

    my $sig = $echo->signature;
    isa_ok $sig, "perl5i::2::Signature";
    ok $sig, '$arg';
    is $sig->num_params, 1;
}


# An anon method
{
    my $echo = method ($arg) {
    };

    my $sig = $echo->signature;
    isa_ok $sig, "perl5i::2::Signature";
    ok $sig, '$arg';
    is $sig->num_params, 1;
    is $sig->invocant, '$self';
    ok $sig->is_method;
}


# A normal subroutine
{
    my $code = sub { return @_ };

    ok !$code->signature;
}


# Stringification
{
    my $signature = '$foo, $bar';
    my $sig = perl5i::2::Signature->new( signature => $signature );
    is $sig, $signature;

    # Make it real.
    is $sig->num_params, 2;
    is $sig, $signature;
}


done_testing;
