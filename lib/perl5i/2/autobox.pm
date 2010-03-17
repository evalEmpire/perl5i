package perl5i::2::autobox;

use strict;
use warnings;

# Load these after we're fully compiled because they
# use us internally.
require perl5i::2::SCALAR;
require perl5i::2::ARRAY;
require perl5i::2::HASH;
require perl5i::2::UNIVERSAL;
require perl5i::2::CODE;

# List::Util needs to be before Core to get the C version of sum
use parent 'autobox::List::Util';
use parent 'autobox::Core';

sub import {
    my $class = shift;
    $class->autobox::import();
    $class->autobox::import(
        UNIVERSAL => 'perl5i::2::UNIVERSAL',
        DEFAULT   => 'perl5i::2::'
    );
    autobox::List::Util::import($class);
    autobox::Core::import($class);
}

1;
