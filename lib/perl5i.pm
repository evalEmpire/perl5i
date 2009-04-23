package perl5i;

use 5.010;

use strict;
use warnings;

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

=cut

sub import {
    require Modern::Perl;
    Modern::Perl->import;

    my $caller = caller;

    # Modern::Perl won't pass this through to our caller.
    require mro;
    mro::set_mro( $caller, 'c3' );

    require CLASS;
    eval qq{
        package $caller;
        CLASS->import;
    } or die $@;
}

1;
