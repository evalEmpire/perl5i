=encoding utf8

=head1 NAME

perl5i::Signature - Representing what parameters a subroutine accepts

=head1 SYNOPSIS

    func hello( $greeting, $place ) { say "$greeting, $place" }

    my $code = \&hello;
    my $signature = $code->signature;

    say $signature->num_params;  # 2
    say $signature->is_method;   # false

=head1 DESCRIPTION

A Signature is a representation of what parameters a subroutine
accepts.  Each subroutine defined with C<def>, C<func> or C<method>
will have a signature associated with it.  You can get at it by
calling the C<signature> method on the code reference.  See
L<perl5i/Signature Introspection> for more details.

Subroutines declared with Perl's built in C<sub> will have no
signature.

=head1 METHODS

=head2 num_params

    my $num_params = $sig->num_params;

The number of parameters the subroutine takes.

=head2 params

    my $params = $sig->params;

An array ref of the parameters a subroutine takes in the order it
takes them.  Currently they are just strings.  In the future they will
be string overloaded objects.

=head2 as_string

    my $params = $sig->as_string;

The original signature string.

=head2 invocant

    my $invocant = $sig->invocant;

The invocant is the object or class a method is called on.
C<invocant> will return the parameter which contains this, by default
it is C<$self> on a method, and nothing a regular subroutine.

=head2 is_method

    my $is_method = $sig->is_method;

Returns if the subroutine was declared as a method.

=head1 OVERLOADING

Signature objects are string overloaded to return C<as_string>.  They
are also I<always true> to avoid objects taking no parameters from
being confused with subroutines with no signatures.
