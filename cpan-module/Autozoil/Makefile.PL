use 5.012004;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Autozoil',
    VERSION_FROM      => 'lib/Autozoil.pm', # finds $VERSION
    EXE_FILES => [
        'autozoil.pl'
    ],
    PREREQ_PM         => {
        'FileHandle' => 0,
        'Getopt::Long' => 0,
        'String::Util' => 0,
        'Test::Deep' => 0,
        'Test::More' => 0,
        'TAP::Harness::JUnit' => 0,
        'XML::Simple' => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
         (ABSTRACT_FROM  => 'lib/Autozoil.pm', # retrieve abstract from module
          AUTHOR         => 'Filip Graliński <filipg@amu.edu.pl>') : ()),
);

