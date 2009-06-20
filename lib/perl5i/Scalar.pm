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
    $string =~ s/(\b\w)/uc($1)/ge;
    return $string;
}

#---------------------------------------------------------------------------
#  whitespace
#---------------------------------------------------------------------------
sub SCALAR::center {
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


#---------------------------------------------------------------------------
#  data type
#---------------------------------------------------------------------------
=pod

is a number
is an integer, decimal... all the stuff from perlfaq4

is a regex

is an object/instance
is a reference

=cut  


1;
