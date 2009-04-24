#!/usr/bin/perl -w

use strict;
use Module::Build;

use 5.010;

my $builder = Module::Build->new(
    module_name         => 'perl5i',
    license             => 'perl',
    dist_author         => 'Michael G Schwern <schwern@pobox.com>',

    requires            => {
        'perl'                  => '5.10.0',
        'Modern::Perl'          => '1.03',
        'CLASS'                 => '1.00',
        'File::stat'            => '1.00',
        'Time::Piece'           => '1.12',
        'Module::Load'          => '0.16',
        'autodie'               => '1.999',
        # Needed for autodie :system
        'IPC::System::Simple'   => '1.18',
        'autobox::Core'         => '0.6',
    },
    build_requires      => {
        'Test::More'            => '0.86',
        'Test::Warn'            => '0.11',
    },
    configure_requires => {
        'Module::Build'         => '0.32',
    },

    meta_merge  => {
        resources => {
            repository =>
              'http://github.com/schwern/perl5i/tree/master',
            bugtracker =>
              'http://github.com/schwern/perl5i/issues',
        },
    },
);

$builder->create_build_script();
