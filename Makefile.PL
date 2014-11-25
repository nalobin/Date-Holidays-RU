use ExtUtils::MakeMaker;
WriteMakefile
(
          'NAME' => 'Date::Holidays::RU',
          'AUTHOR' => 'Alexander Nalobin <alexander@nalobin.ru>',
          'VERSION_FROM' => 'lib/Date/Holidays/RU.pm',
          'PREREQ_PM' => {
                           'Test::More' => '0',
                           'Time::Piece' => '0',
                         },
          'INSTALLDIRS' => 'site',
          'PL_FILES' => {}
        )
;
