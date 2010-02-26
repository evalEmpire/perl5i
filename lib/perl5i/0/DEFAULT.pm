package perl5i::0::DEFAULT;

# Methods which apply to all autoboxed objects

use strict;
use warnings;

use Carp;

BEGIN {
    @SCALAR::ISA = qw(DEFAULT);
    @ARRAY::ISA  = qw(DEFAULT);
    @HASH::ISA   = qw(DEFAULT);
    @CODE::ISA   = qw(DEFAULT);
}

sub DEFAULT::alias {
    my $self = shift;

    croak "Not enough arguments given to alias()" unless @_;

    my @name = @_;
    unshift @name, (caller)[0] unless @name > 1 or grep /::/, @name;

    my $name = join "::", @name;

    no strict 'refs';
    *{$name} = $self;
    return 1;
}

sub DEFAULT::is_number   { return }
sub DEFAULT::is_positive { return }
sub DEFAULT::is_negative { return }
sub DEFAULT::is_int      { return }
sub DEFAULT::is_integer  { return }
sub DEFAULT::is_decimal  { return }

1;
