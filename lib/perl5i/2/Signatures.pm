package perl5i::2::Signatures;

use perl5i::2::Signature;

# Can't load full autoboxing or signatures would not be available to the
# autoboxed definitions
use perl5i::2::CODE;

use base q/Devel::Declare::MethodInstaller::Simple/;
use Sub::Name;

sub import {
    my $class = shift;

    my %opts = @_;
    $opts{into} ||= caller;
    $opts{invocant} ||= '$self';

    my %def_opts = %opts;
    delete $def_opts{invocant};

    # Define "method"
    $class->install_methodhandler(
        name => 'method',
        %opts
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
    if ($invocant) {
        $invocant = $1 if $proto =~ s{^(\$\w+):\s*}{};
        $inject .= "my ${invocant} = shift;";
    }
    $inject .= "my ($proto) = \@_;" if defined $proto and length $proto;

    return $inject;
}

sub code_for {
    my ( $self, $name ) = @_;

    my $signature = $self->{perl5i}{signature};
    my $is_method = $self->{invocant} ? 1 : 0;

    if ( defined $name ) {
        my $pkg = $self->get_curstash_name;
        $name = join( '::', $pkg, $name )
            unless ( $name =~ /::/ );
        return sub (&) {
            my $code = shift;
            ( undef, undef, my $end_line ) = caller();
            # So caller() gets the subroutine name
            no strict 'refs';
            *{$name} = subname $name => $code;

            $self->set_signature(
                code      => $code,
                signature => $signature,
                is_method => $is_method,
                end_line  => $end_line,
            );

            return;
        };
    }
    else {
        return sub (&) {
            my $code = shift;
            ( undef, undef, my $end_line ) = caller();

            $self->set_signature(
                code      => $code,
                signature => $signature,
                is_method => $is_method,
                end_line  => $end_line,
            );
            return $code;
        };
    }
}

sub set_signature {
    my $self = shift;
    my %args = @_;

    my $sig = perl5i::2::CODE::signature( $args{code} );
    return $sig if $sig;

    $sig = perl5i::2::Signature->new(
        signature => $args{signature},
        is_method => $args{is_method},
    );

    perl5i::2::CODE::__set_signature( $args{code}, $sig );

    perl5i::2::CODE::__set_end_line( $args{code}, $args{end_line} )
        if $args{end_line};

    return $sig;
}

1;
