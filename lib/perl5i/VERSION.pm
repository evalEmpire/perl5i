package perl5i::VERSION;

# Just a package to hold the version number and latest major version.

use strict;
use warnings;

use version 0.77; our $VERSION = qv("v2.6.1");

sub latest_version { 2 } # LATEST HERE (for automated update)
sub latest { 'perl5i::' . __PACKAGE__->latest_version }

1;
