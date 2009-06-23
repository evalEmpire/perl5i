package SCALAR;

use strict;
use warnings;
use Carp;

sub center {
    my ($string, $size) = @_;
    carp "Use of uninitialized value for size in center()" if !defined $size;
    $size //= 0;

    my $len             = length $string;

    return $string if $size <= $len;

    my $padlen          = $size - $len;

    # pad right with half the remaining characters
    my $rpad            = int( $padlen / 2 );

    # bias the left padding to one more space, if $size - $len is odd
    my $lpad            = $padlen - $rpad;

    return ' ' x $lpad . $string . ' ' x $rpad;
}

1;
