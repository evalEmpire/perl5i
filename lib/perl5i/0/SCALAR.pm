# vi: set ts=4 sw=4 ht=4 et :
package perl5i::0::SCALAR;
use 5.010;

use strict;
use warnings;
use Carp;
use Module::Load;
use Taint::Util;
use autobox;

sub SCALAR::title_case {
    my ($string) = @_;
    $string =~ s/\b(\w)/\U$1/g;
    return $string;
}


sub SCALAR::center {
    my ($string, $size, $char) = @_;
    carp "Use of uninitialized value for size in center()" if !defined $size;
    $size //= 0;
    $char //= ' ';

    if (length $char > 1) {
        my $bad = $char;
        $char = substr $char, 0, 1;
        carp "'$bad' is longer than one character, using '$char' instead";
    }

    my $len             = length $string;

    return $string if $size <= $len;

    my $padlen          = $size - $len;

    # pad right with half the remaining characters
    my $rpad            = int( $padlen / 2 );

    # bias the left padding to one more space, if $size - $len is odd
    my $lpad            = $padlen - $rpad;

    return $char x $lpad . $string . $char x $rpad;
}


sub SCALAR::ltrim {
    my ($string,$trim_charset) = @_;
    $trim_charset = '\s' unless defined $trim_charset;
    my $re = qr/^[$trim_charset]*/;
    $string =~ s/$re//;
    return $string;
}


sub SCALAR::rtrim {
    my ($string,$trim_charset) = @_;
    $trim_charset = '\s' unless defined $trim_charset;
    my $re = qr/[$trim_charset]*$/;
    $string =~ s/$re//;
    return $string;
}


sub SCALAR::trim {
    return SCALAR::rtrim(SCALAR::ltrim(@_));
}


sub SCALAR::wrap {
    my ($string, %args) = @_;

    my $width     = $args{width}     // 76;
    my $separator = $args{separator} // "\n";

    return $string if $width <= 0;

    load Text::Wrap;
    local $Text::Wrap::separator = $separator;
    local $Text::Wrap::columns   = $width;

    return Text::Wrap::wrap('', '', $string);

}


# untaint the scalar itself, not the reference
sub SCALAR::untaint {
    return $_[0]->mo->untaint if ref $_[0];

    Taint::Util::untaint($_[0]);
    return 1;
}


# untaint the scalar itself, not the reference
sub SCALAR::taint {
    return $_[0]->mo->taint if ref $_[0];

    Taint::Util::taint($_[0]);
    return 1;
}

# Could use the version in Meta but this removes the need to check
# for overloading.
sub SCALAR::is_tainted {
    return ref $_[0] ? Taint::Util::tainted(${$_[0]}) : Taint::Util::tainted($_[0]);
}


sub SCALAR::load {
    goto &Module::Load::load;
}


use POSIX qw{ceil floor};
sub SCALAR::ceil  { ceil($_[0]) }
sub SCALAR::floor { floor($_[0])}

use Scalar::Util qw(looks_like_number);
sub SCALAR::is_number           { looks_like_number($_[0]) }
sub SCALAR::is_positive         { $_[0]->is_number && ($_[0] !~ /^-/) }
sub SCALAR::is_negative         { $_[0]->is_number && ($_[0] =~ /^-/) }
sub SCALAR::is_integer          { $_[0] =~ m{^ [+-]? \d+ $}x }
*SCALAR::is_int = \&SCALAR::is_integer;
sub SCALAR::is_decimal          { $_[0] =~ m{^ [+-]? (?: \d+(?:\.\d*)? | \.\d+ ) $}x }
sub SCALAR::is_float            { $_[0] =~ m{^ [+-]? (?=\d|\.\d) \d* (?:\.\d*)? (?:[Ee](?:[+-]?\d+))? $}x }

1;
