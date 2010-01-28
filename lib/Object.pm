package Object;

use strict;
use warnings;

# Be very careful not to import anything.
require Scalar::Util;
require Carp;
require Taint::Util;
require mro;

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
    my $class = $class->class;

Returns the class of the $object.

When called as a class method, it will return the $class.

Because of ambiguity, it cannot identify a SCALAR object.  It will
instead treat it as a class method call.

=cut

sub class {
    return ref $_[0] ? ref $_[0] : $_[0];
}


=head2 ISA

    my @ISA = $object->ISA;
    my @ISA = $class->ISA;

Returns the immediate parents of the C<$class> or C<$object>.

Essentially equivalent to:

    no strict 'refs';
    my @ISA = @{$class.'::ISA'};

=cut

sub ISA {
    no strict 'refs';

    my $class = ref $_[0] ? ref $_[0] : $_[0];
    return @{$class.'::ISA'};
}


=head2 linear_isa

    my @isa = $class->linear_isa();
    my @isa = $object->linear_isa();

Returns the entire inheritance tree of the $class or $object as a list
in the order it will be searched for method inheritance.

This list includes the $class itself and includes UNIVERSAL and Object.

=cut

sub linear_isa {
    my $self = shift;
    my $class = $self->class;

    my @extra;
    @extra = qw(UNIVERSAL Object) unless $class eq 'UNIVERSAL' or $class eq 'Object';

    # get_linear_isa() does not return UNIVERSAL and does not show Object
    # as a parent of UNIVERSAL.
    return @{mro::get_linear_isa($class)}, @extra;
}


=head2 super

    my @return = $class->super(@args);
    my @return = $object->super(@args);

Call the parent of $class/$object's implementation of the current method.

Equivalent to C<< $object->SUPER::method(@args) >> but based on the
class of the $object rather than the class in which the current method
was declared.

=cut

# A single place to put the "method not found" error.
my $method_not_found = sub {
    my $self   = shift;
    my $method = shift;
    my $class  = $self->class;

    Carp::croak sprintf q[Can't locate object method "%s" via package "%s"],
      $method, $class;
};


# caller() will return if its inside an eval, need to skip over those.
my $find_method = sub {
    my $method;
    my $height = 2;
    do {
        $method = (caller($height))[3];
        $height++;
    } until( !defined $method or $method ne '(eval)' );

    return $method;
};

my $linear_isa = sub {
    my $self  = shift;
    my $prune_to = shift;

    my @isa = (@{mro::get_linear_isa($self->class)}, "UNIVERSAL");
    while(@isa) {
        my $class = shift @isa;
        return @isa if $class eq $prune_to;
    }

    return @isa;
};

sub super {
    # Leave @_ alone.
    my $self = $_[0];

    my $fq_method = $find_method->();
    Carp::croak "super() called outside a method" unless $fq_method;

    my($parent, $method) = $fq_method =~ /^(.*)::(\w+)$/;

    Carp::croak sprintf qq["%s" is not a parent class of "%s"], $parent, $self->class
      unless $self->isa($parent);

    my @isa = $self->$linear_isa($parent);
    for (@isa) {
        my $code = $_->can($method);
        goto &$code;
    }

    $self->$method_not_found($method);
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
        return 0;
    }

    die "Never should be reached";
}


=head2 taint

    $object->taint;

Taints the $object.

Normally only scalars can be tainted, this will throw an exception on
anything else.

Tainted, string overloaded objects will cause this to be a no-op.

An object can override this method if they have a means of tainting
themselves.  Generally this is applicable to string or numeric
overloaded objects who can taint their overloaded value.

=cut

sub taint {
    if( $_[0]->$has_string_overload ) {
        Carp::croak "Untainted overloaded objects cannot normally be made tainted" if
          !$_[0]->is_tainted;
        return 1;
    }
    else {
        Carp::croak "Only scalars can normally be made tainted";
    }

    Carp::confess "Should not be reached";
}


=head2 untaint

    $object->untaint;

Untaints the $object.

Normally objects cannot be tainted, so it is a no op on anything but a
scalar.

Tainted, string overloaded objects will throw an exception.

An object can override this method if they have a means of untainting
themselves.  Generally this is applicable to string or numeric
overloaded objects who can untaint their overloaded value.

=cut

sub untaint {
    if( $_[0]->$has_string_overload && $_[0]->is_tainted ) {
        Carp::croak "Tainted overloaded objects cannot normally be untainted";
    }
    else {
        return 1;
    }

    Carp::confess "Should never be reached";
}


=head2 reftype

    my $reftype = $object->reftype;

Returns the underlying reference type of the $object.

=cut

sub reftype {
    return Scalar::Util::reftype($_[0]);
}

1;
