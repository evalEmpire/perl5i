# vi: set ts=4 sw=4 ht=4 et :
package perl5i;

use 5.010;

use strict;
use warnings;
use Module::Load;
use IO::Handle;
use Carp;
use perl5i::DateTime;
use perl5i::SCALAR;
use Want;

use version 0.77; our $VERSION = qv("v0.1.0");


=head1 NAME

perl5i - Bend Perl 5 so it fits how it works in our imaginations

=head1 SYNOPSIS

  use perl5i;

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
with Perl 5, so perl5i will try to have a lexical effect.

Please add to this imaginary world and help make it real, either by
telling me what Perl looks like in your imagination
(F<http://github.com/schwern/perl5i/issues> or make a fork (forking on
github is like a branch you control) and implement it yourself.

=head1 What it does

perl5i enables each of these modules and adds/changes these functions.
We'll provide a brief description here, but you should look at each of
their documentation for full details.

=head2 alias()

    alias( $name           => $reference );
    alias( $package, $name => $reference );
    alias( @identifiers    => $reference );

Assigns a $refrence a $name.  For example...

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

=cut

sub alias {
    croak "Not enough arguments given to alias()" unless @_ >= 2;

    my $thing = pop @_;
    croak "Last argument to alias() must be a reference" unless ref $thing;

    my @name = @_;
    unshift @name, (caller)[0] unless @name > 1 or grep /::/, @name;

    my $name = join "::", @name;

    no strict 'refs';
    *{$name} = $thing;
    return;
}


=head2 center()

    my $centered_string = $string->center($length);
    my $centered_string = $string->center($length, $character);

Centers $string between $character.  $centered_string will be of
length $length.

C<<$character>> defaults to " ".

    say "Hello"->center(10);        # "   Hello  ";
    say "Hello"->center(10, '-');   # "---Hello--";

C<<center()>> will never truncate C<<$string>>.  If $length is less
than C<<$string->length>> it will just return C<<$string>>.

    say "Hello"->center(4);        # "Hello";

=head2 wrap()

    my $wrapped = $string->wrap( width => $cols, separator => $sep );

Wraps $string to width $cols, breaking lines at word boundries using
separator $sep.

If no width is given, $cols defaults to 76. Default line separator is
the newline character "\n".

See L<Text::Wrap> for details.

=head2 ltrim()

    my $string = '    testme'->ltrim; # 'testme'

Trim leading whitespace (left).

=head2 rtrim()

    my $string = 'testme    '->rtrim; #'testme'

Trim trailing whitespace (right).

=head2 trim()

    my $string = '    testme    '->trim;  #'testme'

Trim both leading and trailing whitespace.

=head2 title_case()

    my $name = 'joe smith'->title_case; #Joe Smith

Will uppercase every word character that follows a wordbreak character.

=head2 die()

C<die> now always returns an exit code of 255 instead of trying to use
C<$!> or C<$?> which makes the exit code unpredictable.  If you want
to exit with a message and a special exit code, use C<warn> then
C<exit>.

=head2 English

L<English> gives English names to the punctuation variables
like C<<$@>> is also C<<$EVAL_ERROR>>.  See L<perlvar> for details.

It does B<not> load the regex variables which effect performance.
C<<$PREMATCH>>, C<<$MATCH>>, and C<<POSTMATCH>> will not exist.  See
C<</p>> in L<perlre> for a better alternative.

=head2 Modern::Perl

Turns on strict and warnings, enables all the 5.10 features like
C<given/when>, C<say> and C<state>, and enables C3 method resolution
order.

=head2 CLASS

Provides C<CLASS> and C<$CLASS> alternatives to C<__PACKAGE__>.

=head2 File::chdir

L<File::chdir> gives you C<$CWD> representing the current working
directory and its assignable to C<<chdir>>.  You can also localize it
to safely chdir inside a scope.

=head2 File::stat

L<File::stat> causes C<stat> to return objects rather than long arrays
which you never remember which bit is which.

=head2 DateTime

C<time>, C<localtime> and C<gmtime> are replaced with DateTime
objects.  They will all act like the core functions.

    # Sat Jan 10 13:37:04 2004
    say scalar gmtime(2**30);

    # 2004
    say gmtime(2**30)->year;

    # 2009 (when this was written)
    say time->year;


=head2 Time::y2038

gmtime() and localtime() will now safely work with dates beyond the
year 2038 and before 1901 (the exact range is not defined, but its
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
(C<open>, C<system> and C<chdir>, for example) to die when they fail.
This means you don't have to put C<or die> at the end of every system
call, but you do have to wrap it in an C<eval> block if you want to
trap the failure.

autodie's default error messages are pretty smart.

All of autodie will be turned on.


=head2 autobox

L<autobox> allows methods to be defined for and called on most unblessed
variables.

=head2 autobox::Core

L<autobox::Core> wraps a lot of Perl's built in functions so they can
be called as methods on unblessed variables.  C<< @a->pop >> for example.

=head2 autobox::List::Util

L<autobox::List::Util> wraps the functions from List::Util
(first, max, maxstr, min, minstr, shuffle, reduce, and sum)
so they can be called on arrays and arrayrefs.

=head2 autobox::dump

L<autobox::dump> defines a C<perl> method that returns L<Data::Dumper>
style serialization of the results of the expression.

=head2 autovivification

L<autovivification> fixes the bug/feature where this:

    $hash = {};
    $hash->{key1}{key2};

Results in C<<$hash->{key1}>> coming into existance.  That will no longer
happen.

=head2 Want

L<Want> generalizes the mechanism of the wantarray function, allowing a 
function to determine the context it's being called in.  Want distinguishes
not just scalar v. array context, but void, lvalue, rvalue, boolean, reference
context and more.  See perldoc L<Want>.


=head1 BUGS

Some parts are not lexical.

See L<http://github.com/schwern/perl5i/issues/labels/bug> for a complete list.

Please report bugs at L<http://github.com/schwern/perl5i/issues/>.


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
chromatic, Ben Hengst and anyone else I've forgotten.

Thanks to Flavian and Matt Trout for their signature and
Devel::Declare work.

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

L<Modern::Perl>


=cut


# This works around their lexical nature.
use parent 'autodie';
# List::Util needs to be before Core to get the C version of sum
use parent 'autobox::List::Util';
use parent 'autobox::Core';
use parent 'autobox::dump';
use parent 'autovivification';


## no critic (Subroutines::RequireArgUnpacking)
sub import {
    my $class = shift;

    require File::stat;

    require Modern::Perl;
    Modern::Perl->import;

    my $caller = caller;

    # Modern::Perl won't pass this through to our caller.
    require mro;
    mro::set_mro( $caller, 'c3' );

    load_in_caller( $caller => (
        ["CLASS"], ["Module::Load"], ["File::chdir"],
        [English => qw(-no_match_vars)],
        ["Want"],
    ) );

    # Have to call both or it won't work.
    autobox::import($class);
    autobox::List::Util::import($class);
    autobox::Core::import($class);
    autobox::dump::import($class);
    autovivification::unimport($class);

    # Export our gmtime() and localtime()
    alias( $caller, 'gmtime',    \&perl5i::DateTime::dt_gmtime );
    alias( $caller, 'localtime', \&perl5i::DateTime::dt_localtime );
    alias( $caller, 'time',      \&perl5i::DateTime::dt_time );
    alias( $caller, 'alias',     \&alias );
    alias( $caller, 'stat',      \&stat );
    alias( $caller, 'lstat',     \&lstat );

    # fix die so that it always returns 255
    *CORE::GLOBAL::die = sub {
        # Leave a single ref be
        local $! = 255;
        return CORE::die(@_) if @_ == 1 and ref $_[0];

        my $error = join '', @_;
        unless ($error =~ /\n$/) {
            my ($file, $line) = (caller)[1,2];
            $error .= " at $file line $line.\n";
        }

        local $! = 255;
        return CORE::die($error);
    };

    # autodie needs a bit more convincing
    @_ = ( $class, ":all" );
    goto &autodie::import;
}


sub load_in_caller {
    my $caller  = shift;
    my @modules = @_;

    for my $spec (@modules) {
        my( $module, @args ) = @$spec;

        load($module);
        ## no critic (BuiltinFunctions::ProhibitStringyEval)
        eval qq{
            package $caller;
            \$module->import(\@args);
            1;
        } or die "Error while perl5i loaded $module => @args: $@";
    }

    return;
}


# File::stat does not play nice in list context
sub stat {
    return CORE::stat(@_) if wantarray;
    return File::stat::stat(@_);
}

sub lstat {
    return CORE::lstat(@_) if wantarray;
    return File::stat::lstat(@_);
}


1;
