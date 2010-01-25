package Object;

use strict;
use warnings;

use Scalar::Util ();

{
    package UNIVERSAL;
    our @ISA = qw(Object);

    # For some reason, UNIVERSAL::isa() doesn't see Object
    # but UNIVERSAL::can() does.  So we fix that.
    my $real_isa = UNIVERSAL->can("isa");
    my $code = sub {
        return 1 if $_[1] eq 'Object';
        goto &$real_isa;
    };
    {
        no warnings 'redefine';
        *isa = $code;
    }
}


=head1 NAME

Object - Everything is an object

=head1 SYNOPSIS

    Class->isa("Object");  # always true

=head1 DESCRIPTION

Object provides a superclass of every object.

It is, in effect, nothing but a better name for UNIVERSAL.

=head1 METHODS

=head2 class

    my $class = $object->class;

Returns the class of the $object.

=cut

sub class {
    my $ref = ref $_[0];
    return $ref if $ref;

    # Not a ref, must be autoboxed
    return ref \$_[0];
}


=head2 reftype

    my $reftype = $object->reftype;

Returns the underlying reference type of the $object.

=cut

sub reftype {
    return Scalar::Util::reftype($_[0]);
}

1;
