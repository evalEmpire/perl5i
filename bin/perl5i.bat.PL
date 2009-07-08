#!/usr/bin/perl -w

my $file = shift;
open my $fh, ">", $file or die "Can't open $file: $!";
printf $fh <<'END', $^X;
@echo off
%s -Mperl5i %%*
END
