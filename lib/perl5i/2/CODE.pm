package perl5i::2::CODE;
use 5.010;

use strict;
use warnings;

require B;

# Can't use sigantures here, Signatures needs CODE.

use Hash::FieldHash qw(fieldhashes);
fieldhashes \my ( %Signatures, %Endline );

sub __set_signature {
    $Signatures{$_[0]} = $_[1];
}

sub signature {
    return $Signatures{$_[0]};
}

sub start_line {
    return B::svref_2object( $_[0] )->START->line;
}

sub __set_end_line {
    return $Endline{$_[0]} = $_[1];
}

sub end_line {
    return $Endline{$_[0]};
}

sub original_name {
    return B::svref_2object( $_[0] )->GV->NAME;
}

sub original_package {
    return B::svref_2object( $_[0] )->GV->STASH->NAME;
}

1;
