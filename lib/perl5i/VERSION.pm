package perl5i::VERSION;

# Just a package to hold the version number and latest major version.

use strict;
use warnings;

use version 0.77; our $VERSION = qv("v2.8.0");

sub latest { "perl5i::2" };     # LATEST HERE (for automated update)

1;
