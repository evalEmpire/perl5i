package SCALAR;

use strict;
use warnings;
use Carp;
use Module::Load;

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

sub wrap {
    my ($string, %args) = @_;

    my $width     = $args{width}     // 76;
    my $separator = $args{separator} // "\n";

    return $string if $width <= 0;

    load Text::Wrap;
    local $Text::Wrap::separator = $separator;
    local $Text::Wrap::columns   = $width;

    return Text::Wrap::wrap('', '', $string);

}

1;
