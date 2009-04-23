package perl5i;

use 5.010;

use strict;
use warnings;
use Module::Load;

our $VERSION = '20090422';


=head1 NAME

perl5i - Bend Perl 5 so it fits how it works in my imagination

=head1 SYNOPSIS

  use perl5i;

=head1 DESCRIPTION

Perl 5 has a lot of warts.  There's a lot of individual modules and
techniques out there to fix those warts.  perl5i aims to pull the best
of them together into one module so you can turn them on all at once.

This includes adding features, changing existing core functions and
changing defaults.  It will likely not be backwards compatible with
Perl 5, so perl5i will have a lexical effect.

=head1 What it does

perl5i enables each of these modules.  We'll provide a brief
description here, but you should look at each of their documentation
for full details.

=head2 Modern::Perl

Turns on strict and warnings, enables all the 5.10 features like
C<given/when>, C<say> and C<state>, and enables C3 method resolution
order.

=head2 CLASS

Provides C<CLASS> and C<$CLASS> alternatives to C<__PACKAGE__>.

=head2 File::stat

=head2 Time::Piece

Causes C<localtime>, C<gmtime> and C<stat> to return objects rather
than long arrays which you never remember which bit is which.

=head2 Module::Load

Adds C<load> which will load a module from a scalar without requiring
you to do funny things like C<eval require $module>.

=head2 autodie

The autodie module causes system and file calls which can fail
(C<open>, C<system> and C<chdir>, for example) to die when they fail.
This means you don't have to put C<or die> at the end of every system
call, but you do have to wrap it in an C<eval> block if you want to
trap the failure.

autodie's default error messages are pretty smart.

All of autodie will be turned on.


=head1 BUGS

Some part are not lexical.

Want to include L<Time::y2038> but it doesn't play nice with
L<Time::Piece> which uses CORE::localtime and CORE::gmtime.


=head1 LICENSE

Copyright 2009, Michael G Schwern <schwern@pobox.com>

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>


=head1 SEE ALSO

Repository:   F<http://github.com/schwern/perl5i/tree/master>
Issues/Bugs:  F<http://github.com/schwern/perl5i/issues>

L<Modern::Perl>


=cut

# This works around autodie's lexical nature.
use base 'autodie';

sub import {
    my $class = shift;

    require Modern::Perl;
    Modern::Perl->import;

    my $caller = caller;

    # Modern::Perl won't pass this through to our caller.
    require mro;
    mro::set_mro( $caller, 'c3' );

    load_in_caller(
        $caller => (
            ["CLASS"],
            ["File::stat"],
            ["Time::Piece"],
            ["Module::Load"],
        )
    );

    @_ = ($class, ":all");
    goto &autodie::import;
}


sub load_in_caller {
    my $caller  = shift;
    my @modules = @_;

    for my $spec (@modules) {
        my($module, @args) = @$spec;

        load($module);
        eval qq{
            package $caller;
            \$module->import(\@args);
            1;
        } or die "Error while perl5i loaded $module => @args: $@";
    }
}

1;
