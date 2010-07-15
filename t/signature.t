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

    $sig = perl5i::2::Signature->new( proto => "  " );
    isa_ok $sig, "perl5i::2::Signature::None";
    is $sig->num_parameters, 0;
    is_deeply $sig->parameters, [];
    is $sig->proto, "  ";
}


# Signature
{
    my $sig = perl5i::2::Signature->new( proto => '$foo' );
    is $sig->num_parameters, 1;
    is_deeply $sig->parameters, ['$foo'];
    is $sig->proto, '$foo';

    $sig = perl5i::2::Signature->new( proto => '$foo , @bar' );
    is $sig->num_parameters, 2;
    is_deeply $sig->parameters, ['$foo', '@bar'];
    is $sig->proto, '$foo , @bar';
}

done_testing;
