# vi: set ts=4 sw=4 ht=4 et :
package perl5i::Scalar;
use 5.010;

use strict;
use warnings;
use Module::Load;
use Carp;


#---------------------------------------------------------------------------
#  string 
#---------------------------------------------------------------------------
sub SCALAR::ucfirst_word {
    my ($string) = @_;
    $string =~ s/\b(\w)/\U$1/g;
    return $string;
}

#---------------------------------------------------------------------------
#  whitespace
#---------------------------------------------------------------------------
# docs for this are still back in perl5i.pm
sub SCALAR::center {
    my ($string, $size, $fill_with) = @_;
    $fill_with = ' ' unless defined $fill_with;

    carp "Use of uninitialized value for size in center()" if !defined $size;
    $size //= 0;

    my $len             = length $string;

    return $string if $size <= $len;

    my $padlen          = $size - $len;

    # pad right with half the remaining characters
    my $rpad            = int( $padlen / 2 );

    # bias the left padding to one more space, if $size - $len is odd
    my $lpad            = $padlen - $rpad;

    return $fill_with x $lpad . $string . $fill_with x $rpad;
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


1;
