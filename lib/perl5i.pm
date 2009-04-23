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

=head2 What it does

=head3 warnings on

=head3 strict on

=head3 5.10 features on

=head3 C3 calling conventions on

=cut

sub import {
    require Modern::Perl;
    Modern::Perl->import;

    # Modern::Perl won't pass this through to our caller.
    require mro;
    mro::set_mro( scalar caller(), 'c3' );
}

1;
