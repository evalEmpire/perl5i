# vi: set ts=4 sw=4 ht=4 et :
package perl5i::2::SCALAR;
use 5.010;

use strict;
use warnings;
require Carp::Fix::1_25;
use perl5i::2::autobox;

sub title_case {
    my ($string) = @_;
    $string =~ s/\b(\w)/\U$1/g;
    return $string;
}


sub center {
    my ($string, $size, $char) = @_;
    Carp::Fix::1_25::carp("Use of uninitialized value for size in center()") if !defined $size;
    $size //= 0;
    $char //= ' ';

    if (length $char > 1) {
        my $bad = $char;
        $char = substr $char, 0, 1;
        Carp::Fix::1_25::carp("'$bad' is longer than one character, using '$char' instead");
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


# Always reverse the scalar, not a single element list.
sub reverse {
    return scalar CORE::reverse $_[0];
}


# Compatiblity wrappers. Remove in 3.0.
sub untaint {
    return $_[0]->mo->untaint;
}

sub taint {
    return $_[0]->mo->taint;
}

sub is_tainted {
    return $_[0]->mo->is_tainted;
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
    Carp::Fix::1_25::croak(<<ERROR) if !ref $_[0];
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
sub is_even             { $_[0]->is_integer && !($_[0] % 2) }
sub is_odd              { $_[0]->is_integer && ($_[0] % 2) }
sub is_decimal          {
    return 0 if !$_[0]->is_number;

    # Fast and reliable way to spot most decimals
    return 1 if ((int($_[0]) - $_[0]) != 0);

    # Final gate for tricky things like 1.0, 1. and .0
    return $_[0] =~ m{^ [+-]? (?: \d+\.\d* | \.\d+ ) $}x;
}

sub group_digits {
    my($self, $opts) = @_;

    state $defaults = {
        thousands_sep   => ",",
        grouping        => 3,
        decimal_point   => ".",
    };

    my $is_money = $opts->{currency};
    my $sep           = $opts->{separator}     // (_get_from_locale("thousands_sep", $is_money)
                                                   || $defaults->{thousands_sep});
    my $grouping      = $opts->{grouping}      // (_get_grouping($is_money)
                                                   || $defaults->{grouping});
    my $decimal_point = $opts->{decimal_point} // (_get_from_locale("decimal_point", $is_money) 
                                                   || $defaults->{decimal_point});
    return $self if $grouping == 0;

    my($integer, $decimal) = split m{\.}, $self, 2;

    $integer = CORE::reverse $integer;
    $integer =~ s/(\d{$grouping})(?=\d)(?!\d*\.)/$1$sep/g;
    $integer = CORE::reverse $integer;

    my $number = $integer;
    $number .= $decimal_point . $decimal if defined $decimal;

    return $number;
}

sub commify {
    my($self, $args) = @_;

    state $defaults = {
        separator       => ",",
        grouping        => 3,
        decimal_point   => ".",
    };

    my $opts = $defaults->merge($args);

    return $self->group_digits( $opts );
}


sub _get_lconv {
    return eval {
        require POSIX;
        POSIX::localeconv();
    } || {};
}

sub _get_grouping {
    my $is_money = shift;
    my $key = $is_money ? "mon_grouping" : "grouping";

    my $lconv = _get_lconv;

    if( $lconv->{$key} ) {
        return (unpack("C*", $lconv->{$key}))[0];
    }
    else {
        return;
    }
}

sub _get_from_locale {
    my($key, $is_money) = @_;
    $key = "mon_$key" if $is_money;

    my $lconv = _get_lconv;
    return $lconv->{$key};
}


sub path2module {
    my $path = shift;

    my($vol, $dirs, $file) = File::Spec->splitpath($path);
    my @dirs = grep length, File::Spec->splitdir($dirs);

    Carp::Fix::1_25::croak("'$path' does not look like a Perl module path")
      if $file !~ m{\.pm$} or File::Spec->file_name_is_absolute($path);

    $file =~ s{\.pm$}{};

    my $module = join "::", @dirs, $file;
    Carp::Fix::1_25::croak("'$module' is not a valid module name") unless $module->is_module_name;

    return $module;
}


sub is_module_name {
    my $name = shift;

    return 0 unless defined($name);

    return 0 unless $name =~ qr{\A 
                                [[:alpha:]_]            # Must start with an alpha or _
                                [[:word:]]*             # Then any number of alpha numerics or _
                                (?: :: [[:word:]]+ )*   # Then optional ::word's
                                \z
                              }x;

    return 1;
}


sub module2path {
    my $module = shift;

    Carp::Fix::1_25::croak("'$module' is not a valid module name") unless $module->is_module_name;

    my @parts = split /::/, $module;
    $parts[-1] .= ".pm";

    return join "/", @parts;
}

1;
