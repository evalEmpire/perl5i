package Object;

use strict;
use warnings;

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


1;

__END__

=head1 NAME

Object - Everything is an object

=head1 SYNOPSIS

    Class->isa("Object");  # always true

=head1 DESCRIPTION

Object provides a superclass of every object.

It is, in effect, nothing but a better name for UNIVERSAL.

=cut
