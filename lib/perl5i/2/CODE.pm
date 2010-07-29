package perl5i::2::CODE;
use 5.010;

use strict;
use warnings;

# Can't use sigantures here, Signatures needs CODE.

use Hash::FieldHash qw(fieldhashes);
fieldhashes \my(%Signatures);

sub __set_signature {
    $Signatures{$_[0]} = $_[1];
}

sub signature {
    return $Signatures{$_[0]};
}

1;
