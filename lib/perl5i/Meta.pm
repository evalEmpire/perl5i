=encoding utf8

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


=head2 Meta Instance vs Meta Class

Each object has a meta object for their instance, accessable with C<<
$obj->mo >> and also a meta object for their class, accessable with
C<< $obj->mc >>.  The meta instance can do most everything the meta
class can, mc is provided mostly for disambiguation.

The problem is this:

    my $thing = "Foo";
    say $thing->mo->class;

In perl5i, everything is an object.  Do you want the class of $thing
or do you want to treat $thing as a class name?  Its ambiguous.  So to
disambiguate, use C<< $thing->mc >> when you mean $thing to be a class
name and C<< $thing->mo >> when you mean it to be an object.

For example, when writing a method which could be a class or could be
an object be sure to use C<< $proto->mc->class >> to get the class
name.

    sub my_method {
        my $proto = shift;  # could be an object, could be a class name
        my $class = $proto->mc->class;
        ....
    }


=head1 METHODS

=head2 class

    my $class = $object->mo->class;
    my $class = $class->mc->class;

Returns the class of the $object or $class.

=head2 ISA

    my @ISA = $object->mo->ISA;
    my @ISA = $class->mc->ISA;

Returns the immediate parents of the C<$class> or C<$object>.

Essentially equivalent to:

    no strict 'refs';
    my @ISA = @{$class.'::ISA'};


=head2 linear_isa

    my @isa = $class->mc->linear_isa();
    my @isa = $object->mo->linear_isa();

Returns the entire inheritance tree of the $class or $object as a list
in the order it will be searched for method inheritance.

This list includes the $class itself and includes UNIVERSAL.  For example:

    package Child;
    use parent qw(Parent);

    # Child, Parent, UNIVERSAL
    my @isa = Child->mo->linear_isa();


=head2 super

    my @return = $class->mc->super(@args);
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

=head2 checksum

    my $checksum = $object->mo->checksum;
    my $md5    = $object->mo->checksum( algorithm => 'md5' );
    my $base64 = $object->mo->checksum( format => 'base64' );

Get a digest of the object's contents, taking its class into account.

Two different objects can have the same checksum if their contents
are identical. Likewise, a single object can have different checksums
throughout its life cycle if it's mutable. This means its checksum
will change if its internal state changes.

For example,

    $obj->mo->checksum( format => 'base64', algorithm => 'md5' );

=head3 options

=over 4

=item algorithm

The checksum algorithm.  Can be C<sha1> and C<md5>.

Defaults to sha1.

=item format

The character set of the checksum, can be C<hex>, C<base64>, or
C<binary>.

Defaults to hex.

=back

=head2 is_equal

    $object->mo->is_equal($other_object)

Assess whether something is equal to something else, recurring over deep
data structures and treating overloaded objects as numbers or strings
when appropriate.

Examples:

    my $prices = { chair => 50, table => 300 };
    my $other  = { chair => 50, table => [250, 255] };

    say "They are equal" if $prices->mo->is_equal($other);


    my $uri = URI->new("http://www.perl.org");
    $uri->mo->is_equal("http://www.perl.org") # True

=head2 perl

    my $dump = $object->mo->perl;

Dumps the contents of the $object as Perl in a string, like Data::Dumper.

=head2 dump

    my $dump = $object->mo->dump( format => $format );

Dumps the contents of the $object as a string in whatever format you like.

Possible formats are yaml, json and perl.

$format defaults to "perl" which is equivalent to C<< $object->mo->perl >>.
