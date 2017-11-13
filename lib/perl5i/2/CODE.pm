package perl5i::2::CODE;
use 5.010;

use strict;
use warnings;

# Can't use signatures here, Signatures needs CODE.

use Hash::FieldHash qw(fieldhashes);
fieldhashes \my(%Signatures);

sub __set_signature {
    $Signatures{$_[0]} = $_[1];
}

sub signature {
    return $Signatures{$_[0]};
}

sub is_constant {
    require B;
    # Use eval to take advantage of compile-time constants.
    eval '
        no warnings "redefine";
        sub is_constant {
            not not B::svref_2object($_[0])->CvFLAGS & B::CVf_CONST
        }
    ';
    goto &is_constant;
}

1;
