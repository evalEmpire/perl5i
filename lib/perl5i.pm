package perl5i;

######################################
# The real code is in perl5i::2      #
# Please patch that                  #
######################################

use strict;
use perl5i::VERSION; our $VERSION = perl5i::VERSION->VERSION;

my $Latest = perl5i::VERSION->latest;

sub import {
    require Carp;
    Carp::croak(<<END);
perl5i will break compatibility in the future, you can't just "use perl5i".

Instead, "use $Latest" which will guarantee compatibility with all
features supplied in that major version.

Type "perldoc perl5i" for details in the section "Using perl5i".
END
}

1;

__END__

=head1 NAME

perl5i - Fix as much of Perl 5 as possible in one pragma

=head1 SYNOPSIS

  use perl5i::2;

  or

  $ perl5i your_script.pl

=head1 DESCRIPTION

Perl 5 has a lot of warts.  There's a lot of individual modules and
techniques out there to fix those warts.  perl5i aims to pull the best
of them together into one module so you can turn them on all at once.

This includes adding features, changing existing core functions and
changing defaults.  It will likely not be 100% backwards compatible
with Perl 5, though it will be 99%, perl5i will try to have a lexical
effect.

Please add to this imaginary world and help make it real, either by
telling me what Perl looks like in your imagination
(F<http://github.com/schwern/perl5i/issues>) or make a fork (forking on
github is like a branch you control) and implement it yourself.


=head1 Using perl5i

Because perl5i I<plans> to be incompatible in the future, you do not
simply C<use perl5i>.  You must declare which major version of perl5i
you are using.  You do this like so:

    # Use perl5i major version 1
    use perl5i::2;

Thus the code you write with, for example, C<perl5i::2> will always
remain compatible even as perl5i moves on.

If you want to be daring, you can C<use perl5i::latest> to get the
latest version.

If you want your module to depend on perl5i, you should depend on the
versioned class.  For example, depend on C<perl5i::2> and not
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


=head2 Autoboxing

L<autobox> allows methods to be defined for and called on most
unblessed variables.  This means you can call methods on ordinary
strings, lists and hashes!  It also means perl5i can add a lot of
functionality without polluting the global namespace.

L<autobox::Core> wraps a lot of Perl's built in functions so they can
be called as methods on unblessed variables.  C<< @a->pop >> for example.

=head2 alias()

    $scalar_reference->alias( @identifiers );
    @alias->alias( @identifiers );
    %hash->alias( @identifiers );
    (\&code)->alias( @identifiers );

Aliases a variable to a new global name.

    my $code = sub { 42 };
    $code->alias( "foo" );
    print foo();        # prints 42

It will work on everything except scalar references.

    our %stuff;
    %other_hash->alias( "stuff" );  # %stuff now aliased to %other_hash

It is not a copy, changes to one will change the other.

    my %things = (foo => 23);
    our %stuff;
    %things->alias( "stuff" );  # alias %things to %stuff
    $stuff{foo} = 42;           # change %stuff
    say $things{foo};           # and it will show up in %things

Multiple @identifiers will be joined with '::' and used as the fully
qualified name for the alias.

    my $class = "Some::Class";
    my $name  = "foo";
    sub { 99 }->alias( $class, $name );
    print Some::Class->foo;  # prints 99

If there is just one @identifier and it has no "::" in it, the current
caller will be prepended.  C<< $thing->alias("name") >> is shorthand for
C<< $thing->alias(CLASS, "name") >>

Due to limitations in autobox, non-reference scalars cannot be
aliased.  Alias a scalar ref instead.

    my $thing = 23;
    $thing->alias("foo");  # error

    my $thing = \23;
    $thing->alias("foo");  # $foo is now aliased to $thing

This is basically a nicer way to say:

    no strict 'refs';
    *{$package . '::'. $name} = $reference;


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

=head2 round

    my $rounded_number = $number->round;

Round to the nearest integer.

=head2 round_up

=head2 ceil

    my $new_number = $number->round_up;

Rounds the $number up.

    2.45->round_up;  # 3

ceil() is a synonym for round_up().


=head2 round_down

=head2 floor

    my $new_number = $number->round_down;

Rounds the $number down.

    2.45->round_down; # 2

floor() is a synonyn for round_down().


=head2 is_number

    $is_a_number = $thing->is_number;

Returns true if $thing is a number understood by Perl.

    12.34->is_number;           # true
    "12.34"->is_number;         # also true
    "eleven"->is_number;        # false

=head2 is_positive

    $is_positive = $thing->is_positive;

Returns true if $thing is a positive number.

0 is not positive.

=head2 is_negative

    $is_negative = $thing->is_negative;

Returns true if $thing is a negative number.

0 is not negative.

=head2 is_integer

    $is_an_integer = $thing->is_integer;

Returns true if $thing is an integer.

    12->is_integer;             # true
    12.34->is_integer;          # false
    "eleven"->is_integer;       # false

=head2 is_int

A synonym for is_integer

=head2 is_decimal

    $is_a_decimal_number = $thing->is_decimal;

Returns true if $thing is a decimal number.

    12->is_decimal;             # false
    12.34->is_decimal;          # true
    ".34"->is_decimal;          # true
    "point five"->is_decimal;   # false

=head2 require

    my $module = $module->require;

Will C<require> the given $module.  This avoids funny things like
C<eval qq[require $module] or die $@>.  It accepts only module names.

On failure it will throw an exception, just like C<require>.  On a
success it returns the $module.  This is mostly useful so that you can
immediately call $module's C<import> method to emulate a C<use>.

    # like "use $module qw(foo bar);" if that worked
    $module->require->import(qw(foo bar));

    # like "use $module;" if that worked
    $module->require->import;

=head3 wrap()

    my $wrapped = $string->wrap( width => $cols, separator => $sep );

Wraps $string to width $cols, breaking lines at word boundries using
separator $sep.

If no width is given, $cols defaults to 76. Default line separator is
the newline character "\n".

See L<Text::Wrap> for details.

=head3 ltrim()

=head3 rtrim()

=head3 trim()

    my $trimmed = $string->trim;
    my $trimmed = $string->trim($character_set);

Trim whitespace.  ltrim() trims off the start of the string (left),
rtrim() off the end (right) and trim() off both the start and end.

    my $string = '    testme'->ltrim;        # 'testme'
    my $string = 'testme    '->rtrim;        # 'testme'
    my $string = '    testme    '->trim;     # 'testme'

They all take an optional $character_set which will determine what
characters should be trimmed.  It follows regex character set syntax
so C<A-Z> will trim everything from A to Z.  Defaults to C<\s>,
whitespace.

    my $string = '-> test <-'->trim('-><');  # ' test '   


=head3 title_case()

    my $name = 'joe smith'->title_case;   # Joe Smith

Will uppercase every word character that follows a wordbreak character.


=head3 path2module()

    my $module = $path->path2module;

Given a relative $path it will return the Perl module this represents.
For example,

    "Foo/Bar.pm"->path2module;  # "Foo::Bar"

It will throw an exception if given something which could not be a
path to a Perl module.

=head2 module2path()

    my $path = $module->module2path;

Will return the relative $path in which the Perl $module can be found.
For example,

    "Foo::Bar"->module2path;  # "Foo/Bar.pm"


=head2 List Autoboxing

All the functions from L<List::Util> and select ones from
L<List::MoreUtils> are all available as methods on unblessed arrays and array refs.

first, max, maxstr, min, minstr, minmax, shuffle, reduce, sum, any,
all, none, true, false, uniq and mesh.

The have all been altered to return array refs where applicable in
order to allow chaining.

    @array->grep(sub{ $_->is_number })->sum->say;

=head3 diff()

Calculate the difference between two (or more) arrays:

    my @a = ( 1, 2, 3 );
    my @b = ( 3, 4, 5 );

    my @diff_a = @a->diff(\@b) # [ 1, 2 ]
    my @diff_b = @b->diff(\@a) # [ 4, 5 ]

Diff returns all elements in array C<@a> that are not present in array
C<@b>. Item order is not considered: two identical elements in both
arrays will be recognized as such disregarding their index.

    [ qw( foo bar ) ]->diff( [ qw( bar foo ) ] ) # empty, they are equal

For comparing more than two arrays:

    @a->diff(\@b, \@c, ... )

All comparisons are against the base array (C<@a> in this example). The
result will be composed of all those elements that were present in C<@a>
and in none other.

It also works with nested data structures; it will traverse them
depth-first to assess whether they are identical or not. For instance:

    [ [ 'foo ' ], { bar => 1 } ]->diff([ 'foo' ]) # [ { bar => 1 } ]

In the case of overloaded objects (i.e., L<DateTime>, L<URI>,
L<Path::Class>, etc.), it tries its best to treat them as strings or numbers.

    my $uri  = URI->new("http://www.perl.com");
    my $uri2 = URI->new("http://www.perl.com");

    [ $uri ]->diff( [ "http://www.perl.com" ] ); # empty, they are equal
    [ $uri ]->diff( [ $uri2 ] );                 # empty, they are equal


=head3 intersect()

    my @a = (1 .. 10);
    my @b = (5 .. 15);

    my @intersection = @a->intersect(\@b) # [ 5 .. 10 ];

Performs intersection between arrays, returning those elements that are
present in all of the argument arrays simultaneously.

As with C<diff()>, it works with any number of arrays, nested data
structures of arbitrary depth, and handles overloaded objects
graciously.

=head2 Hash Autoboxing

=head3 flip()

Exchanges values for keys in a hash.

    my %things = ( foo => 1, bar => 2, baz => 5 );
    my %flipped = %things->flip; # { 1 => foo, 2 => bar, 5 => baz }

If there is more than one occurence of a certain value, any one of the
keys may end up as the value.  This is because of the random ordering
of hash keys.

    # Could be { 1 => foo }, { 1 => bar }, or { 1 => baz }
    { foo => 1, bar => 1, baz => 1 }->flip;

Because hash references cannot usefully be keys, it will not work on
nested hashes.

    { foo => [ 'bar', 'baz' ] }->flip; # dies


=head3 merge()

Recursively merge two or more hashes together using L<Hash::Merge::Simple>.

    my $a = { a => 1 };
    my $b = { b => 2, c => 3 };

    $a->merge($b); # { a => 1, b => 2, c => 3 }

For conflicting keys, rightmost precedence is used:

    my $a = { a => 1 };
    my $b = { a => 100, b => 2};

    $a->merge($b); # { a => 100, b => 2 }
    $b->merge($a); # { a => 1,   b => 2 }

It also works with nested hashes, although it won't attempt to merge
array references or objects. For more information, look at the
L<Hash::Merge::Simple> docs.

=head3 diff()

    my %staff    = ( bob => 42, martha => 35, timmy => 23 );
    my %promoted = ( timmy => 23 );

    %staff->diff(\%promoted); # { bob => 42, martha => 35 }

Returns the key/value pairs present in the first hash that are not
present in the subsequent hash arguments.  Otherwise works as
C<< @array->diff >>.

=head3 intersect()

    %staff->intersect(\%promoted); # { timmy => 23 }

Returns the key/value pairs that are present simultaneously in all the
hash arguments.  Otherwise works as C<< @array->intersect >>.

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

C<@ARGV> will be read as UTF8.

STDOUT, STDIN, STDERR and all newly opened filehandles will have UTF8
encoding turned on.  Consequently, if you want to output raw bytes to
a file, such as outputting an image, you must set C<< binmode $fh >>.

=head2 Carp

C<croak> and C<carp> from L<Carp> are always available.

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

C<gmtime()> and C<localtime()> will now safely work with dates beyond
the year 2038 and before 1901.  The exact range is not defined, but we
guarantee at least up to 2**47 and back to year 1.


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

=head2 No indirect object syntax

perl5i turns indirect object syntax, ie. C<new $obj>, into a compile
time error.  Indirect object syntax is largely unnecessary and
removing it avoids a number of ambiguous cases where Perl will
mistakenly try to turn a function call into an indirect method call.

See L<indirect> for details.

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

=head1 Command line program

There is a perl5i command line program installed with perl5i (Windows
users get perl5i.bat).  This is handy for writing one liners.

    perl5i -e 'gmtime->year->say'

And you can use it on the C<#!> line.

    #!/usr/bin/perl5i

    gmtime->year->say;


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
chromatic, Ben Hengst, Bruno Vecchi and anyone else I've forgotten.

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

Frequently Asked Questions about perl5i: L<perl5ifaq>

Some modules with similar purposes include:
L<Modern::Perl>, L<Common::Sense>

For a complete object declaration system, see L<Moose> and
L<MooseX::Declare>.
