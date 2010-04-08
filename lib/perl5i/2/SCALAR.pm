# vi: set ts=4 sw=4 ht=4 et :
package perl5i::2::SCALAR;
use 5.010;

use strict;
use warnings;
require Carp;
use perl5i::2::autobox;

sub title_case {
    my ($string) = @_;
    $string =~ s/\b(\w)/\U$1/g;
    return $string;
}


sub center {
    my ($string, $size, $char) = @_;
    Carp::carp("Use of uninitialized value for size in center()") if !defined $size;
    $size //= 0;
    $char //= ' ';

    if (length $char > 1) {
        my $bad = $char;
        $char = substr $char, 0, 1;
        Carp::carp("'$bad' is longer than one character, using '$char' instead");
    }

    my $len             = length $string;

    return $string if $size <= $len;

    my $padlen          = $size - $len;

    # pad right with half the remaining characters
    my $rpad            = int( $padlen / 2 );

    # bias the left padding to one more space, if $size - $len is odd
    my $lpad            = $padlen - $rpad;

    return $char x $lpad . $string . $char x $rpad;
}


sub ltrim {
    my ($string,$trim_charset) = @_;
    $trim_charset = '\s' unless defined $trim_charset;
    my $re = qr/^[$trim_charset]*/;
    $string =~ s/$re//;
    return $string;
}


sub rtrim {
    my ($string,$trim_charset) = @_;
    $trim_charset = '\s' unless defined $trim_charset;
    my $re = qr/[$trim_charset]*$/;
    $string =~ s/$re//;
    return $string;
}


sub trim {
    my $charset = $_[1];

    return rtrim(ltrim($_[0], $charset), $charset);
}


sub wrap {
    my ($string, %args) = @_;

    my $width     = $args{width}     // 76;
    my $separator = $args{separator} // "\n";

    return $string if $width <= 0;

    require Text::Wrap;
    local $Text::Wrap::separator = $separator;
    local $Text::Wrap::columns   = $width;

    return Text::Wrap::wrap('', '', $string);

}


# untaint the scalar itself, not the reference
sub untaint {
    return $_[0]->mo->untaint if ref $_[0];

    require Taint::Util;
    Taint::Util::untaint($_[0]);
    return 1;
}


# untaint the scalar itself, not the reference
sub taint {
    return $_[0]->mo->taint if ref $_[0];

    require Taint::Util;
    Taint::Util::taint($_[0]);
    return 1;
}

# Could use the version in Meta but this removes the need to check
# for overloading.
sub is_tainted {
    require Taint::Util;
    return ref $_[0] ? Taint::Util::tainted(${$_[0]}) : Taint::Util::tainted($_[0]);
}


sub require {
    my $error = do {
        # Don't let them leak out or get reset
        local($!,$@);
        return $_[0] if eval { require $_[0]->module2path };
        $@;
    };

    my($pack, $file, $line) = caller;
    $error =~ s{ at .*? line .*?\.\n$}{ at $file line $line.\n};
    die $error;
}


sub alias {
    Carp::croak(<<ERROR) if !ref $_[0];
Due to limitations in autoboxing, scalars cannot be aliased.
Sorry.  Use a scalar reference instead.
ERROR

    goto &perl5i::2::UNIVERSAL::alias;
}


require POSIX;
*ceil  = \&POSIX::ceil;
*floor = \&POSIX::floor;
*round_up   = \&ceil;
*round_down = \&floor;
sub round {
    return 0 if $_[0] == 0;

    if( $_[0]->is_positive ) {
        abs($_[0] - int($_[0])) < 0.5 ? round_down($_[0])
                                      : round_up($_[0])
    }
    else {
        abs($_[0] - int($_[0])) < 0.5 ? round_up($_[0])
                                      : round_down($_[0])
    }
}

require Scalar::Util;
*is_number = \&Scalar::Util::looks_like_number;
sub is_positive         { $_[0]->is_number && $_[0] > 0 }
sub is_negative         { $_[0]->is_number && $_[0] < 0 }
sub is_integer          {
    return 0 if !$_[0]->is_number;
    return $_[0] =~ m{ ^[+-]? \d+ $}x;
}
*is_int = \&is_integer;
sub is_decimal          {
    return 0 if !$_[0]->is_number;

    # Fast and reliable way to spot most decimals
    return 1 if ((int($_[0]) - $_[0]) != 0);

    # Final gate for tricky things like 1.0, 1. and .0
    return $_[0] =~ m{^ [+-]? (?: \d+\.\d* | \.\d+ ) $}x;
}

sub group_digits {
    my $self = shift;
    my %opts = @_;

    state $defaults = {
        thousands_sep   => ",",
        grouping        => 3,
    };

    my $sep      = $opts{seperator} // (_get_thousands_sep() || $defaults->{thousands_sep});
    my $grouping = $opts{grouping}  // (_get_grouping()      || $defaults->{grouping});
    return $self if $grouping == 0;

    my $number = reverse $self;
    $number =~ s/(\d{$grouping})(?=\d)(?!\d*\.)/$1$sep/g;
    return reverse $number;
}

sub commify {
    my $self = shift;
    my %args = @_;

    state $defaults = {
        seperator   => ",",
        grouping    => 3,
    };

    my $opts = $defaults->merge(\%args);

    return $self->group_digits( %$opts );
}


sub _get_lconv {
    return eval {
        require POSIX;
        POSIX::localeconv();
    } || {};
}

sub _get_grouping {
    my $lconv = _get_lconv;

    if( $lconv->{grouping} ) {
        return (unpack("C*", $lconv->{grouping}))[0];
    }
    else {
        return;
    }
}

sub _get_thousands_sep {
    my $lconv = _get_lconv;
    return $lconv->{thousands_sep};
}


sub path2module {
    my $path = shift;

    my($vol, $dirs, $file) = File::Spec->splitpath($path);
    my @dirs = grep length, File::Spec->splitdir($dirs);

    Carp::croak("'$path' does not look like a Perl module path")
      if $file !~ m{\.pm$} or File::Spec->file_name_is_absolute($path);

    $file =~ s{\.pm$}{};

    return join "::", @dirs, $file;
}


sub module2path {
    my $module = shift;

    my @parts = split /::/, $module;
    $parts[-1] .= ".pm";

    return join "/", @parts;
}

1;
