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
=head2 title()
        
    my $name = 'joe smith'->title; #Joe Smith

Will uppercase every word character that follows a wordbreak character.

=cut

    
sub SCALAR::title {
    my ($string) = @_;
    $string =~ s/\b(\w)/\U$1/g;
    return $string;
}

#---------------------------------------------------------------------------
#  whitespace
#---------------------------------------------------------------------------
=head2 center()

    my $centered_string = $string->center($length);

Centers $string between spaces.  $centered_string will be of length
$length.

If $length is less than C<<$string->length>> it will just return
C<<$string>>.

    say "Hello"->center(10);   # "   Hello  ";
    say "Hello"->center(4);    # "Hello";

    my $centered_string = $string->center($length, $character);

Centers $string as above, but uses the character in $character 
instead of space.

    say "Hello"->center(10, '-');   # "---Hello--"
    say "Hello"->center(4, '-');    # "Hello";

=cut


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

=head2 ltrim()

    my $string = '    testme'->ltrim; # 'testme'

Trim leading whitespace (left).

=cut

sub SCALAR::ltrim {
    my ($string,$trim_charset) = @_;
    $trim_charset = '\s' unless defined $trim_charset;
    my $re = qr/^[$trim_charset]*/;
    $string =~ s/$re//;
    return $string;
}

=head2 rtrim()

    my $string = 'testme    '->rtrim; #'testme'

Trim trailing whitespace (right).

=cut

sub SCALAR::rtrim {
    my ($string,$trim_charset) = @_;
    $trim_charset = '\s' unless defined $trim_charset;
    my $re = qr/[$trim_charset]*$/;
    $string =~ s/$re//;
    return $string;
}

=head2 trim()

    my $string = '    testme    '->trim;  #'testme'

Trim both leading and trailing whitespace.

=cut

sub SCALAR::trim {
    return SCALAR::rtrim(SCALAR::ltrim(@_));
}


1;
