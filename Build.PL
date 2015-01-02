#!/usr/bin/perl -w

use strict;

# Include 'lib' so it sees our perl5i::VERSION when version checking
use lib 'inc', 'lib';
use MyBuild;

use 5.010;

my $builder = MyBuild->new(
    module_name => 'perl5i',
    license     => 'perl',
    dist_author => 'Michael G Schwern <schwern@pobox.com>',
    dist_version => "v2.13.1",

    requires => {
        'perl'                    => '5.10.0',
        'Modern::Perl'            => '1.03',
        'CLASS'                   => '1.00',
        'Child'                   => '0.009',
        'DateTime'                => '0.47',
        'DateTime::Format::Epoch' => '0.11',
        'DateTime::TimeZone::Tzfile' => '0.002',
        # for perl5i::1
        'Module::Load'            => '0.16',
        'Text::Wrap'              => '2009.0305',
        'Try::Tiny'               => '0.02',
        # plays nice with open pragma, Debian stable version
        'autodie'                 => '2.12',
        # Needed for autodie :system
        'IPC::System::Simple' => '1.18',
        'autobox'             => '2.80',
        'autobox::Core'       => '1.0',
        parent                => '0.221',
        'File::chdir'         => '0.1002',
        # for perl5i::1
        'autobox::dump'       => '20090426',
        'autobox::List::Util' => '20090629',
        'Want'                => '0.18',
        'autovivification'    => '0.06',
        'version'             => '0.77',
        'Perl6::Caller'       => '0.100',
        "Taint::Util"         => '0.06',
        'Hash::Merge::Simple' => '0.04',
        'List::MoreUtils'     => '0.22',
        indirect              => '0.24',
        'JSON'                => '2.17',
        'YAML::Any'           => '0.70',
        'Digest::SHA'         => '5.45',
        'Digest::MD5'         => '2.36',
        'Object::ID'          => '0.1.0',
        "Devel::Declare::MethodInstaller::Simple"       => '0.006009',
        'true::VERSION'       => '0.16',
        'Capture::Tiny'       => '0.06',
        # Change to how @ARGV is handled, wraps glob and <>.
        'utf8::all'           => '0.015',
        'Carp::Fix::1_25'     => '1.000000',
        'Hash::StoredIterator' => '0.007',
        'Hash::FieldHash'     => '0.06',
        'Path::Tiny'          => '0.036',
        'Import::Into'        => '1.002003',
    },
    build_requires => {
        'ExtUtils::CBuilder' => '0.26',
        'Test::More'         => '0.88',
        'Test::Warn'         => '0.11',
        'IPC::Open3'         => '0',
        'Test::Output'       => '0.16',
    },
    configure_requires => {
        # MB's auto configure requires only puts it in the META.yml
        # so some CPAN shells won't see it.
        "Module::Build"      => '0.36',
    },
    recommends => {
        # Significant performance improvements
        autodie         => '2.26',
    },

    meta_merge => {
        resources => {
            repository  => 'http://github.com/evalEmpire/perl5i/tree/master',
            bugtracker  => 'http://github.com/evalEmpire/perl5i/issues',
            IRC         => "irc://irc.perl.org/#perl5i",
        },
        no_index => {
            file  => [qw(
                lib/perl5i/0/DateTime.pm
                lib/perl5i/0/ARRAY.pm
                lib/perl5i/0/DEFAULT.pm
                lib/perl5i/0/HASH.pm
                lib/perl5i/0/Meta.pm
                lib/perl5i/0/Meta/Class.pm
                lib/perl5i/0/Meta/Instance.pm
                lib/perl5i/0/SCALAR.pm
                lib/perl5i/VERSION.pm
            )],
        },
    },

    PL_files => {
        'bin/perl5i.c.PL'       => 'bin/perl5i.c',
        'bin/perl5i.bat.PL'     => 'bin/perl5i.bat',
    },

    recursive_test_files => 1,

    create_readme       => 1,
    create_license      => 1,
);

$builder->requires->{"Time::y2038"} = "20100218" if $builder->needs_y2038;

$builder->create_build_script();
