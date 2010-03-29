package perl5i::latest;

use strict;
use perl5i::VERSION; our $VERSION = perl5i::VERSION->VERSION;

my $Latest;
BEGIN { $Latest = perl5i::VERSION->latest; }

use parent ($Latest);
sub import { goto &{$Latest .'::import'} }

1;

__END__

=encoding utf8

=head1 NAME

perl5i::latest - Use the latest version of perl5i

=head1 SYNOPSIS

    use perl5i::latest;

=head1 DESCRIPTION

Because perl5i is designed to break compatibility, you must declare
which major version you're writing your code with to preserve
compatibility.  If you want to be more daring, you can C<use
perl5i::latest> and it will load the newest major version of perl5i
you have installed.

perl5i B<WILL BREAK COMPATIBILITY>, believe it.  This is mostly useful
for one-off scripts and one-liners and digital thrill seekers.

=cut
