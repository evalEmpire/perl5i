=head1 NAME

perl5i::Meta - The perl5i meta object


=head1 SYNOPSIS

    use perl5i;

    my $id      = $object->mo->id;
    my $class   = $object->mo->class;
    ...and so on...


=head1 DESCRIPTION

Each object has a meta object which can be used to describe and
sometimes alter the object.  This is for things which are common to
*all* objects.  For example, C<< $obj->mo->id >> for a universal
object identifier.  C<<@ISA = $obj->mo->ISA >> to get an object's
parents.  And so on.


=head2 Why a meta object?

Why not just stick these methods in UNIVERSAL?  They'd clash with
user-space methods.  For example, if an existing class has its own
C<id()> method it would likely clash with what our C<id()> method
does.  You want to guarantee that every object responds to these meta
methods the same way so there's no second-guessing.


=head1 METHODS

=head2 class

    my $class = $object->mo->class;
    my $class = $class->mo->class;

Returns the class of the $object.

When called as a class method, it will return the $class.

Because of ambiguity, it cannot identify a SCALAR object.  It will
instead treat it as a class method call.


=head2 ISA

    my @ISA = $object->mo->ISA;
    my @ISA = $class->mo->ISA;

Returns the immediate parents of the C<$class> or C<$object>.

Essentially equivalent to:

    no strict 'refs';
    my @ISA = @{$class.'::ISA'};


=head2 linear_isa

    my @isa = $class->mo->linear_isa();
    my @isa = $object->mo->linear_isa();

Returns the entire inheritance tree of the $class or $object as a list
in the order it will be searched for method inheritance.

This list includes the $class itself and includes UNIVERSAL.  For example:

    package Child;
    use parent qw(Parent);

    # Child, Parent, UNIVERSAL
    my @isa = Child->mo->linear_isa();


=head2 super

    my @return = $class->mo->super(@args);
    my @return = $object->mo->super(@args);

Call the parent of $class/$object's implementation of the current method.

Equivalent to C<< $object->SUPER::method(@args) >> but based on the
class of the $object rather than the class in which the current method
was declared.


=head2 is_tainted

    my $is_tainted = $object->mo->is_tainted;

Returns true if the $object is tainted.

Only scalars can be tainted, so objects generally return false.

String and numerically overloaded objects will check against their
overloaded versions.


=head2 taint

    $object->mo->taint;

Taints the $object.

Normally only scalars can be tainted, this will throw an exception on
anything else.

Tainted, string overloaded objects will cause this to be a no-op.

An object can override this method if they have a means of tainting
themselves.  Generally this is applicable to string or numeric
overloaded objects who can taint their overloaded value.


=head2 untaint

    $object->mo->untaint;

Untaints the $object.

Normally objects cannot be tainted, so it is a no op on anything but a
scalar.

Tainted, string overloaded objects will throw an exception.

An object can override this method if they have a means of untainting
themselves.  Generally this is applicable to string or numeric
overloaded objects who can untaint their overloaded value.


=head2 reftype

    my $reftype = $object->mo->reftype;

Returns the underlying reference type of the $object.
