package Object;

use strict;
use warnings;

# Be very careful not to import anything.
require Scalar::Util;
require Carp;
require Taint::Util;

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


=head2 is_tainted

    my $is_tainted = $object->is_tainted;

Returns true if the $object is tainted.

Only scalars can be tainted, so objects generally return false.

String and numerically overloaded objects will check against their
overloaded versions.

=cut

# Returns the code which will run when the object is used as a string
my $has_string_overload = sub {
    return overload::Method($_[0], q[""]) || overload::Method($_[0], q[0+])
};

sub is_tainted {
    my $code;

    if( $code = overload::Method($_[0], q[""]) ) {
        return Taint::Util::tainted($code->($_[0]));
    }
    elsif( $code = overload::Method($_[0], "0+") ) {
        # Don't do a +0 as that might trigger a + operation which
        # might be seperately overloaded, or as in DateTime just die.
        return Taint::Util::tainted($code->($_[0]));
    }
    else {
        return Taint::Util::tainted($_[0]);
    }

    die "Never should be reached";
}


=head2 taint

    $object->taint;

Taints the $object.

Normally only scalars can be tainted, this will throw an exception on
anything else.

An object can override this method if they have a means of tainting
themselves.  Generally this is applicable to string or numeric
overloaded objects who can taint their overloaded value.

=cut

sub taint {
    if( $_[0]->$has_string_overload ) {
        Carp::croak "Overloaded objects cannot be made tainted" unless $_[0]->is_tainted;
        return 1;
    }

    Taint::Util::taint($_[0]);
    return 1;
}

=head2 untaint

    $object->untaint;

Untaints the $object.

Normally objects cannot be tainted, so it is a no op on anything but a
scalar.

String and numeric overloaded objects are an exception.  If an object
is string or numeric overloaded, and it is tainted, this method will
throw an exception.  The overloaded class may override this method to
provide their own untainting mechanism.

=cut

sub untaint {
    if( $_[0]->$has_string_overload ) {
        Carp::croak "Overloaded objects cannot be untainted" if $_[0]->is_tainted;
        return 1;
    }
    else {
        return 1;
    }
}


=head2 reftype

    my $reftype = $object->reftype;

Returns the underlying reference type of the $object.

=cut

sub reftype {
    return Scalar::Util::reftype($_[0]);
}

1;
