package perl5i;

use perl5i::VERSION; our $VERSION = perl5i::VERSION->VERSION;

my $Latest = perl5i::VERSION->latest;

sub import {
    require Carp;
    Carp::croak(<<END);
perl5i will break compatibility in the future, you can't just "use perl5i".

Instead, "use $Latest" which will guarantee compatibility with all
feature supplied in that major version.

Type "perldoc perl5i" for details in the section "Using perl5i".

NOTE:  Version 0 does not guarantee compatibility.  Version 1 and up will.
END
}

1;

__END__
