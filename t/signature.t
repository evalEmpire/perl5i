#!/usr/bin/perl

use perl5i::2;
use perl5i::2::Signature;
use Test::More;

# Empty signature
{
    my $sig = perl5i::2::Signature->new( proto => "" );
    isa_ok $sig, "perl5i::2::Signature::None";
    is $sig->num_parameters, 0;
    is_deeply $sig->parameters, [];
    is $sig->proto, "";
    is $sig->invocant, '';
    ok !$sig->is_method;
}


# Empty signature with spaces
{
    my $sig = perl5i::2::Signature->new( proto => "  " );
    isa_ok $sig, "perl5i::2::Signature::None";
    is $sig->num_parameters, 0;
    is_deeply $sig->parameters, [];
    is $sig->proto, "  ";
    is $sig->invocant, '';
    ok !$sig->is_method;
}


# Empty signature on a method
{
    my $sig = perl5i::2::Signature->new( proto => "  ", is_method => 1 );
    isa_ok $sig, "perl5i::2::Signature::None";
    is $sig->num_parameters, 0;
    is_deeply $sig->parameters, [];
    is $sig->proto, "  ";
    is $sig->invocant, '$self';
    ok $sig->is_method;
}


# One arg signature
{
    my $sig = perl5i::2::Signature->new( proto => '$foo' );
    isa_ok $sig, "perl5i::2::Signature";
    is $sig->num_parameters, 1;
    is_deeply $sig->parameters, ['$foo'];
    is $sig->proto, '$foo';
    isa_ok $sig, "perl5i::2::Signature::Real";
    $sig->invocant, '';
    ok !$sig->is_method;
}


# Two arg signature
{
    my $sig = perl5i::2::Signature->new( proto => '$foo , @bar' );
    is $sig->num_parameters, 2;
    is_deeply $sig->parameters, ['$foo', '@bar'];
    is $sig->proto, '$foo , @bar';
    $sig->invocant, '';
    ok !$sig->is_method;
}


# With leading and trailing spaces
{
    my $sig = perl5i::2::Signature->new( proto => ' $foo , @bar ' );
    is $sig->num_parameters, 2;
    is_deeply $sig->parameters, ['$foo', '@bar'];
    is $sig->proto, ' $foo , @bar ';  # an exact reproduction
    $sig->invocant, '';
    ok !$sig->is_method;
}


# With an invocant
{
    my $sig = perl5i::2::Signature->new( proto => '$class: @bar', is_method => 1 );
    is $sig->num_parameters, 1;
    is_deeply $sig->parameters, ['@bar'];
    is $sig->proto, '$class: @bar';
    is $sig->invocant, '$class';
    ok $sig->is_method;
}


# Method, implied invocant
{
    my $sig = perl5i::2::Signature->new( proto => '@bar', is_method => 1 );
    is $sig->num_parameters, 1;
    is_deeply $sig->parameters, ['@bar'];
    is $sig->proto, '@bar';
    is $sig->invocant, '$self';
    ok $sig->is_method;
}


done_testing;
