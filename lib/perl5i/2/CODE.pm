package perl5i::2::CODE;
use 5.010;

use strict;
use warnings;

use perl5i::2::Signatures;

use Hash::FieldHash qw(fieldhashes);
fieldhashes \my(%Signatures);

method __set_signature($signature) {
    $Signatures{$self} = $signature;
}

method signature() {
    return $Signatures{$self};
}

1;
