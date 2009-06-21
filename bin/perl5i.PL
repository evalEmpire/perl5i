# Write bin/perl5i with the appropriate perl

my $file = shift;

open my $fh, ">", $file or die "Can't open bin/perl5i for writing: $!";
printf $fh <<'OUT', $^X;
#!/bin/sh

exec %s -Mperl5i "$@"

: <<=cut
=pod

=head1 NAME

perl5i - Bend Perl 5 so it fits how it works in my imagination

=head1 SYNOPSIS

  $ perl5i your_script.pl

=head1 DESCRIPTION

Perl 5 has a lot of warts.  There's a lot of individual modules and
techniques out there to fix those warts.  perl5i aims to pull the best
of them together into one module so you can turn them on all at once.

This includes adding features, changing existing core functions and
changing defaults.  It will likely not be backwards compatible with
Perl 5, so perl5i will try to have a lexical effect.

=head1 SEE ALSO

The bulk of this command is implemented in the L<perl5i> module.  Refer
to that module's documentation for complete information on specific
improvements provided by perl5i.

Repository:   F<http://github.com/schwern/perl5i/tree/master>
Issues/Bugs:  F<http://github.com/schwern/perl5i/issues>

=head1 LICENSE

Copyright 2009, Michael G Schwern <schwern@pobox.com>

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

See F<http://www.perl.com/perl/misc/Artistic.html>

=cut
OUT

chmod 0755, $file;
