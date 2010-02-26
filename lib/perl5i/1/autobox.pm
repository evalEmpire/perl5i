package perl5i::1::autobox;

use strict;
use warnings;

# Load these after we're fully compiled because they
# use us internally.
require perl5i::1::SCALAR;
require perl5i::1::ARRAY;
require perl5i::1::HASH;
require perl5i::1::UNIVERSAL;
require perl5i::1::CODE;

# List::Util needs to be before Core to get the C version of sum
use parent 'autobox::List::Util';
use parent 'autobox::Core';
use parent 'autobox::dump';

sub import {
    my $class = shift;
    $class->autobox::import();
    $class->autobox::import(
        UNIVERSAL => 'perl5i::1::UNIVERSAL',
        DEFAULT   => 'perl5i::1::'
    );
    autobox::List::Util::import($class);
    autobox::Core::import($class);
    autobox::dump::import($class);
}

1;
