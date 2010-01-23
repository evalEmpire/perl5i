#!/usr/bin/perl -w

use strict;
use lib 'inc';
use MyBuild;

use 5.010;

my $builder = MyBuild->new(
    module_name => 'perl5i',
    license     => 'perl',
    dist_author => 'Michael G Schwern <schwern@pobox.com>',

    requires => {
        'perl'                    => '5.10.0',
        'Modern::Perl'            => '1.03',
        'CLASS'                   => '1.00',
        'DateTime'                => '0.47',
        'DateTime::Format::Epoch' => '0.11',
        'Time::y2038'             => '20081111',
        'Module::Load'            => '0.16',
        'Text::Wrap'              => '2009.0305',
        'autodie'                 => '1.999',
        # Needed for autodie :system
        'IPC::System::Simple' => '1.18',
        'autobox::Core'       => '0.6',
        parent                => '0.221',
        'File::chdir'         => '0.1002',
        'autobox::dump'       => '20090426',
        'autobox::List::Util' => '20090629',
        'Want'                => '0.18',
        'autovivification'    => '0.04',
        'version'             => '0.77',
    },
    build_requires => {
        'ExtUtils::CBuilder' => '0.26',
        'Test::More'         => '0.88',
        'Test::Warn'         => '0.11',
        'IPC::Open3'         => '0',
    },
    configure_requires => {
        'Module::Build' => '0.32',
    },

    meta_merge => {
        resources => {
            repository => 'http://github.com/schwern/perl5i/tree/master',
            bugtracker => 'http://github.com/schwern/perl5i/issues',
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

$builder->create_build_script();
