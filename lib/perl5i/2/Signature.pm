{
    package perl5i::2::Signature;
    use perl5i::2;

    # A proxy class to hold a method's signature until its actually used.

    method new($class: %args) {
        my $proto = $args{proto} // '';

        if( !$proto || $proto !~ /\S/ ) {
            return perl5i::2::Signature::None->new( proto => $proto);
        }
        else {
            return bless { proto => $proto }, $class;
        }
    }


    method make_real() {
        bless $self, "perl5i::2::Signature::Real";

        $self->__parse_prototype;
    }

    # Upgrade to a real signature object
    # and call the original method.
    # This should only be called once per object.
    our $AUTOLOAD;
    def AUTOLOAD {
        my $self = $_[0];  # leave @_ alone

        # Upgrade to a real object
        $self->make_real;

        my($method) = reverse split /::/, $AUTOLOAD;

        goto $self->can($method);
    }
}


{
    package perl5i::2::Signature::None;
    use perl5i::2;

    method new($class: %args) {
        return bless { proto => $args{proto} }, $class;
    }

    sub num_parameters { 0 }
    sub parameters { return []; }
    sub make_real {}

    method proto {
        return $self->{proto};
    }
}


{
    package perl5i::2::Signature::Real;
    use perl5i::2;

    method new($class: %args) {
        bless $class, \%args
    }

    sub make_real {}

    method __parse_prototype {
        my @args = split /\s*,\s*/, $self->{proto};
        $self->{parameters}     = \@args;
        $self->{num_parameters} = @args;
    }

    method num_parameters() {
        return $self->{num_parameters};
    }

    method parameters() {
        return $self->{parameters};
    }

    method proto() {
        return $self->{proto};
    }
}

1;
