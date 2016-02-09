use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Monit::HTTP',
    AUTHOR              => 'Angelo "pallotron" Failla <pallotron@freaknet.org>',
    VERSION_FROM        => 'lib/Monit/HTTP.pm',
    ABSTRACT_FROM       => 'lib/Monit/HTTP.pm',
    EXE_FILES           => [qw( mm )],
    PL_FILES            => { },
    PREREQ_PM => {
        'HTTP::Tiny' => 0,
        'XML::Fast' => 0,
        'YAML' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Test::MockModule' => 0,
        'Test::Trap' => 0,
        'Test::Pod::Coverage' => 1.08,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Monit-HTTP-*' },
);
