package perl5i::2::Signatures;

use perl5i::2::autobox;
use perl5i::2::Signature;

use base q/Devel::Declare::MethodInstaller::Simple/;
use Sub::Name;

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

    # Save it for attaching to the code ref later
    $self->{perl5i}{signature} = $proto;

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


sub code_for {
    my ($self, $name) = @_;

    if (defined $name) {
        my $pkg = $self->get_curstash_name;
        $name = join( '::', $pkg, $name )
          unless( $name =~ /::/ );
        return sub (&) {
            my $code = shift;
            # So caller() gets the subroutine name
            no strict 'refs';
            *{$name} = subname $name => $code;

            $self->set_signature($code);

            return;
        };
    } else {
        return sub (&) {
            my $code = shift;

            $self->set_signature($code);
            return $code;
        };
    }
}


sub set_signature {
    my $self = shift;
    my $code = shift;

    my $sig = perl5i::2::Signature->new(
        signature => $self->{perl5i}{signature},
        is_method => $self->{name} eq 'method' ? 1 : 0
    );
    $code->__set_signature( $sig );

    return $sig;
}

1;
