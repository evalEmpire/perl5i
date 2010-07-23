package perl5i::2::UNIVERSAL;

# Methods which apply to all autoboxed objects

use strict;
use warnings;

require Carp;

sub alias {
    my $self = shift;

    Carp::croak("Not enough arguments given to alias()") unless @_;

    my @name = @_;
    unshift @name, (caller)[0] unless @name > 1 or grep /::/, @name;

    my $name = join "::", @name;

    no strict 'refs';
    *{$name} = $self;
    return 1;
}

sub is_number   { return }
sub is_positive { return }
sub is_negative { return }
sub is_even     { return }
sub is_odd      { return }
sub is_int      { return }
sub is_integer  { return }
sub is_decimal  { return }

1;
