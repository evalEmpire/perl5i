# Write bin/perl5i with the appropriate perl

my $file = shift;

open my $fh, ">", $file or die "Can't open bin/perl5i for writing: $!";
printf $fh <<'OUT', $^X;
#!/bin/sh

exec %s -Mperl5i "$@"
OUT

chmod 0755, $file;
