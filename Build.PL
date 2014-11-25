use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Date::Holidays::RU',
    license             => 'perl',
    dist_author         => 'Alexander Nalobin <alexander@nalobin.ru>',
    dist_version_from   => 'lib/Date/Holidays/RU.pm',
    create_makefile_pl  => 'traditional',
    build_requires => {
        'Test::More' => '0',
        'Time::Piece' => '0',
    },
);

$builder->create_build_script();

1;