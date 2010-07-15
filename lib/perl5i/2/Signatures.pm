package perl5i::2::Signatures;

use v5.10;
use strict;
use warnings;

use base q/Devel::Declare::MethodInstaller::Simple/;

sub import {
    my $class = shift;

    my %opts  = @_;
    $opts{into}     ||= caller;
    $opts{invocant} ||= '$self';

    my %def_opts = %opts;
    delete $def_opts{invocant};

    # Define "method"
    $class->install_methodhandler(
      name => 'method',
      %opts
    );

    # Define "def"
    $class->install_methodhandler(
      name => 'def',
      %def_opts
    );

    # Define "func"
    $class->install_methodhandler(
      name => 'func',
      %def_opts
    );
}

sub parse_proto {
    my $self = shift;
    my ($proto) = @_;
    $proto ||= '';
    $proto =~ s/[\r\n]//g;
    my $invocant = $self->{invocant};

    my $inject = '';
    if( $invocant ) {
        $invocant = $1 if $proto =~ s{^(\$\w+):\s*}{};
        $inject .= "my ${invocant} = shift;";
    }
    $inject .= "my ($proto) = \@_;" if defined $proto and length $proto;

    return $inject;
}

1;
