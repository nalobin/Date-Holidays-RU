#!perl -T

use utf8;
use Test::More tests => 7;

BEGIN {
	use_ok( 'Date::Holidays::RU', qw( is_holiday is_ru_holiday ) );
}

diag( "Testing Date::Holidays::RU $Date::Holidays::RU::VERSION, Perl $]" );

is is_holiday( 2015, 1, 1 ), 'Новогодние каникулы', 'holiday';
ok !is_holiday( 2014, 1, 10 ), 'business day';

is is_holiday( 2014, 3, 10 ), 'Перенос праздничного дня', 'moved holiday';
ok !is_holiday( 2013, 10, 3 ), 'not moved holiday';

ok is_holiday( 2030, 11, 4 ), q{my daughter's birthday always will be holiday :)};

is is_ru_holiday( 2015, 1, 1 ), is_holiday( 2015, 1, 1 ), 'alias';



