package perl5i;

######################################
# The real code is in perl5i::0      #
# Please patch that                  #
######################################

use perl5i::VERSION; our $VERSION = perl5i::VERSION->VERSION;

my $Latest = perl5i::VERSION->latest;

sub import {
    require Carp;
    Carp::croak(<<END);
perl5i will break compatibility in the future, you can't just "use perl5i".

Instead, "use $Latest" which will guarantee compatibility with all
feature supplied in that major version.

Type "perldoc perl5i" for details in the section "Using perl5i".

NOTE:  Version 0 does not guarantee compatibility.  Version 1 and up will.
END
}

1;

__END__

=head1 NAME

perl5i - Fix as much of Perl 5 as possible in one pragma

=head1 SYNOPSIS

  use perl5i::0;

  or

  $ perl5i your_script.pl

=head1 DESCRIPTION

B<THIS MODULE'S INTERFACE IS UNSTABLE!> It's still a playground.
Features may be added, changed and removed without notice.  C<use
perl5i> may not even work in the future.  See
L<http://github.com/schwern/perl5i/issues/issue/69> and
L<http://github.com/schwern/perl5i/issues/issue/60> for details.  You
have been warned.

Perl 5 has a lot of warts.  There's a lot of individual modules and
techniques out there to fix those warts.  perl5i aims to pull the best
of them together into one module so you can turn them on all at once.

This includes adding features, changing existing core functions and
changing defaults.  It will likely not be 100% backwards compatible
with Perl 5, though it will be 99%, but perl5i will try to have a
lexical effect.

Please add to this imaginary world and help make it real, either by
telling me what Perl looks like in your imagination
(F<http://github.com/schwern/perl5i/issues>) or make a fork (forking on
github is like a branch you control) and implement it yourself.


=head1 Using perl5i

Because perl5i I<plans> to be incompatible in the future, you do not
simply C<use perl5i>.  You must declare which major version of perl5i
you are using.  You do this like so:

    # Use perl5i major version 0
    use perl5i::0;

While version 0 does not guarante to be compatibility, 1 and up will.
Thus the code you write with, for example, C<perl5i::2> will always
remain compatible even as perl5i moves on.

If you want to be daring, you can C<use perl5i::latest> to get the
latest version.

If you want your module to depend on perl5i, you should depend on the
versioned class.  For example, depend on C<perl5i::0> and not
C<perl5i>.

See L</VERSIONING> for more information about perl5i's versioning
scheme.


=head1 What it does

perl5i enables each of these modules and adds/changes these functions.
We'll provide a brief description here, but you should look at each of
their documentation for full details.


=head2 The Meta Object

Every object (and everything is an object) now has a meta object
associated with it.  Using the meta object you can ask things about
the object which were previously over complicated.  For example...

    # the object's class
    my $class = $obj->mo->class;

    # its parent classes
    my @isa = $obj->mo->isa;

    # the complete inheritance hierarchy
    my @complete_isa = $obj->mo->linear_isa;

    # the reference type of the object
    my $reftype = $obj->mo->reftype;

A meta object is used to avoid polluting the global method space.
C<mo> was chosen to avoid clashing with Moose's meta object.

See L<perl5i::Meta> for complete details.


=head2 alias()

    alias( $name           => $reference );
    alias( $package, $name => $reference );
    alias( @identifiers    => $reference );

Assigns a $reference a $name.  For example...

    alias foo => sub { 42 };
    print foo();        # prints 42

It will also work on hash, array and scalar refs.

    our %stuff;
    alias stuff => \%some_other_hash;

Multiple @identifiers will be joined with '::' and used as the fully
qualified name for the alias.

    my $class = "Some::Class";
    my $name  = "foo";
    alias $class, $name => sub { 99 };
    print Some::Class->foo;  # prints 99

If the $name has no "::" in it, the current caller will be prepended.

This is basically a nicer way to say:

    no strict 'refs';
    *{$package . '::'. $name} = $reference;

=head2 Autoboxing

L<autobox> allows methods to be defined for and called on most
unblessed variables.  This means you can call methods on ordinary
strings, lists and hashes!  It also means perl5i can add a lot of
functionality without polluting the global namespace.

L<autobox::Core> wraps a lot of Perl's built in functions so they can
be called as methods on unblessed variables.  C<< @a->pop >> for example.

=head3 perl()

L<autobox::dump> defines a C<perl> method that returns L<Data::Dumper>
style serialization of the results of the expression.  It should work
on any scalar, list, hash or reference.


=head2 Scalar Autoboxing

perl5i adds some methods to scalars of its own.

=head3 center()

    my $centered_string = $string->center($length);
    my $centered_string = $string->center($length, $character);

Centers $string between $character.  $centered_string will be of
length $length.

C<$character> defaults to " ".

    say "Hello"->center(10);        # "   Hello  ";
    say "Hello"->center(10, '-');   # "---Hello--";

C<center()> will never truncate C<$string>.  If $length is less
than C<< $string->length >> it will just return C<$string>.

    say "Hello"->center(4);        # "Hello";

=head3 wrap()

    my $wrapped = $string->wrap( width => $cols, separator => $sep );

Wraps $string to width $cols, breaking lines at word boundries using
separator $sep.

If no width is given, $cols defaults to 76. Default line separator is
the newline character "\n".

See L<Text::Wrap> for details.

=head3 ltrim()

    my $string = '    testme'->ltrim; # 'testme'

Trim leading whitespace (left).

=head3 rtrim()

    my $string = 'testme    '->rtrim; #'testme'

Trim trailing whitespace (right).

=head3 trim()

    my $string = '    testme    '->trim;  #'testme'

Trim both leading and trailing whitespace.

=head3 title_case()

    my $name = 'joe smith'->title_case; #Joe Smith

Will uppercase every word character that follows a wordbreak character.


=head2 List Autoboxing

L<autobox::List::Util> wraps the functions from L<List::Util>
(first, max, maxstr, min, minstr, shuffle, reduce, and sum)
so they can be called on arrays and arrayrefs.

=head2 caller()

L<Perl6::Caller> causes C<caller> to return an object in scalar
context.

=head2 die()

C<die> now always returns an exit code of 255 instead of trying to use
C<$!> or C<$?> which makes the exit code unpredictable.  If you want
to exit with a message and a special exit code, use C<warn> then
C<exit>.

=head2 utf8

L<utf8> lets you put UTF8 encoded strings into your source code.
This means UTF8 variable and method names, strings and regexes.

It means strings will be treated as a set of characters rather than a
set of bytes.  For example, C<length> will return the number of
characters, not the number of bytes.

    length("perl5i is MËTÁŁ");  # 15, not 18


=head2 English

L<English> gives English names to the punctuation variables; for
instance, C<<$@>> is also C<<$EVAL_ERROR>>.  See L<perlvar> for
details.

It does B<not> load the regex variables which affect performance.
C<$PREMATCH>, C<$MATCH>, and C<$POSTMATCH> will not exist.  See
the C<p> modifier in L<perlre> for a better alternative.

=head2 Modern::Perl

L<Modern::Perl> turns on strict and warnings, enables all the 5.10
features like C<given/when>, C<say> and C<state>, and enables C3
method resolution order.

=head2 CLASS

Provides C<CLASS> and C<$CLASS> alternatives to C<__PACKAGE__>.

=head2 File::chdir

L<File::chdir> gives you C<$CWD> representing the current working
directory and it's assignable to C<chdir>.  You can also localize it
to safely chdir inside a scope.

=head2 File::stat

L<File::stat> causes C<stat> to return an object in scalar context.

=head2 DateTime

C<time>, C<localtime>, and C<gmtime> are replaced with DateTime
objects.  They will all act like the core functions.

    # Sat Jan 10 13:37:04 2004
    say scalar gmtime(2**30);

    # 2004
    say gmtime(2**30)->year;

    # 2009 (when this was written)
    say time->year;


=head2 Time::y2038

C<gmtime()> and C<localtime()> will now safely work with dates beyond the
year 2038 and before 1901 (the exact range is not defined, but it's
well into a couple million years in either direction).


=head2 Module::Load

L<Module::Load> adds C<load> which will load a module from a scalar
without requiring you to do funny things like C<eval require $module>.


=head2 IO::Handle

Turns filehandles into objects so you can call methods on them.  The
biggest one is C<autoflush> rather than mucking around with C<$|> and
C<select>.

    $fh->autoflush(1);


=head2 autodie

L<autodie> causes system and file calls which can fail
(C<open>, C<system>, and C<chdir>, for example) to die when they fail.
This means you don't have to put C<or die> at the end of every system
call, but you do have to wrap it in an C<eval> block if you want to
trap the failure.

autodie's default error messages are pretty smart.

All of autodie will be turned on.


=head2 autovivification

L<autovivification> fixes the bug/feature where this:

    $hash = {};
    $hash->{key1}{key2};

Results in C<< $hash->{key1} >> coming into existence.  That will no longer
happen.

=head2 want()

C<want()> generalizes the mechanism of the wantarray function, allowing a
function to determine the context it's being called in.  Want distinguishes
not just scalar v. array context, but void, lvalue, rvalue, boolean, reference
context, and more.  See perldoc L<Want> for full details.

=head2 Try::Tiny

L<Try::Tiny> gives support for try/catch blocks as an alternative to
C<eval BLOCK>. This allows correct error handling with proper localization
of $@ and a nice syntax layer:

        # handle errors with a catch handler
        try {
                die "foo";
        } catch {
                warn "caught error: $_";
        };

        # just silence errors
        try {
                die "foo";
        };

See perldoc L<Try::Tiny> for details.

=head1 BUGS

Some parts are not lexical.

See L<http://github.com/schwern/perl5i/issues/labels/bug> for a complete list.

Please report bugs at L<http://github.com/schwern/perl5i/issues/> or
email L<mailto:perl5i@googlegroups.com>.


=head1 VERSIONING

perl5i follows the Semantic Versioning policy, L<http://semver.org>.
In short...

Versions will be of the form X.Y.Z.

0.Y.Z may change anything at any time.

Incrementing X (ie. 1.2.3 -> 2.0.0) indicates a backwards incompatible change.

Incrementing Y (ie. 1.2.3 -> 1.3.0) indicates a new feature.

Incrementing Z (ie. 1.2.3 -> 1.2.4) indicates a bug fix or other internal change.


=head1 NOTES

Inspired by chromatic's L<Modern::Perl> and in particular
F<http://www.modernperlbooks.com/mt/2009/04/ugly-perl-a-lesson-in-the-importance-of-language-design.html>.

I totally didn't come up with the "Perl 5 + i" joke.  I think it was
Damian Conway.


=head1 THANKS

Thanks to our contributors: Chas Owens, Darian Patrick, rjbs,
chromatic, Ben Hengst, and anyone else I've forgotten.

Thanks to Flavian and Matt Trout for their signature and
L<Devel::Declare> work.

Thanks to all the CPAN authors upon whom this builds.

=head1 LICENSE

Copyright 2009-2010, Michael G Schwern <schwern@pobox.com>

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>


=head1 SEE ALSO

Repository:   L<http://github.com/schwern/perl5i/tree/master>
Issues/Bugs:  L<http://github.com/schwern/perl5i/issues>
IRC:          irc.perl.org on the #perl5i channel
Mailing List: L<http://groups.google.com/group/perl5i/>

Some modules with similar purposes include:
L<Modern::Perl>, L<Common::Sense>

For a complete object declaration system, see L<Moose> and
L<MooseX::Declare>.


