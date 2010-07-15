{
    package perl5i::2::Signature;
    use perl5i::2;

    # A proxy class to hold a method's signature until its actually used.

    method new($class: %args) {
        my $proto = $args{proto} // '';
        my $is_method = $args{is_method} // 0;

        my $empty_proto = !$proto || $proto !~ /\S/;
        if( $empty_proto ) {
            return $is_method ? perl5i::2::Signature::Method::None->new( proto => $proto)
                              : perl5i::2::Signature::Function::None->new( proto => $proto);
        }
        else {
            return bless { proto => $proto, is_method => $is_method }, $class;
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
        my($method) = reverse split /::/, $AUTOLOAD;
        return if $method eq 'DESTROY';

        my $self = $_[0];  # leave @_ alone

        # Upgrade to a real object
        $self->make_real;

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
    package perl5i::2::Signature::Method::None;
    use parent -norequire, 'perl5i::2::Signature::None';

    sub invocant { return '$self' }
    sub is_method { return 1 }
}


{
    package perl5i::2::Signature::Function::None;
    use parent -norequire, 'perl5i::2::Signature::None';

    sub invocant  { return '' }
    sub is_method { return 0 }
}


{
    package perl5i::2::Signature::Real;
    use perl5i::2;

    method new($class: %args) {
        bless \%args, $class;
    }

    sub make_real {}

    method __parse_prototype {
        my $proto = $self->{proto}->trim;

        if( $proto =~ s{^ (\$\w+) : \s*}{}x ) {
            $self->{invocant} = $1 // '';
        }
        elsif( $self->is_method ) {
            $self->{invocant} = '$self';
        }
        else {
            $self->{invocant} = '';
        }

        my @args = split /\s*,\s*/, $proto;

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

    method invocant() {
        return $self->{invocant};
    }

    method is_method() {
        return $self->{is_method};
    }
}

1;
