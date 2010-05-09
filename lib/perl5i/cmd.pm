package perl5i::cmd;

# This is a shim for the perl5i command line utility to use.

use strict;
use parent 'perl5i::latest';

sub import {
    my($class, $name) = @_;

    # Make the program identify as perl5i
    $^X = $name;

    goto &perl5i::latest::import;
}

1;
