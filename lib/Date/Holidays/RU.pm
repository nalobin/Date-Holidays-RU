package Date::Holidays::RU;

=encoding utf8

=head1 NAME

Date::Holidays::RU - Determine Russian Federation official holidays and business days.

=head1 SYNOPSIS

    use Date::Holidays::RU qw( is_holiday holidays is_business_day );

    binmode STDOUT, ':encoding(UTF-8)';
   
    my ( $year, $month, $day ) = ( localtime )[ 5, 4, 3 ];
    $year  += 1900;
    $month += 1;

    if ( my $holidayname = is_holiday( $year, $month, $day ) ) {
        print "Today is a holiday: $holidayname\n";
    }
    
    my $ref = holidays( $year );
    while ( my ( $md, $name ) = each %$ref ) {
        print "On $md there is a holiday named $name\n";
    }
    
    if ( is_business_day( 2012, 03, 11 ) ) {
        print "2012-03-11 is business day on weekend\n";
    }
=cut

use warnings;
use strict;
use utf8;
use base 'Exporter';
use vars qw/$VERSION @EXPORT_OK/;
$VERSION = '0.03';
@EXPORT_OK = qw(
    is_holiday
    is_ru_holiday
    holidays
    is_business_day
    is_short_business_day
);

use Time::Piece;

# this list is not valid before 2005
my %HOLIDAYS_YEARLY = (
    '0101' => 'Новогодние каникулы',
    '0102' => 'Новогодние каникулы',
    '0103' => 'Новогодние каникулы',
    '0104' => 'Новогодние каникулы',
    '0105' => 'Новогодние каникулы',
    '0106' => 'Новогодние каникулы',
    '0107' => 'Рождество Христово',
    '0108' => 'Новогодние каникулы',
    '0223' => 'День защитника Отечества',
    '0308' => 'Международный женский день',
    '0501' => 'Праздник Весны и Труда',
    '0509' => 'День Победы',
    '0612' => 'День России',
    '1104' => 'День народного единства',
);

my %HOLIDAYS_SPECIAL = (
    2005 => [ qw( 0110 0307 0502 0613 ) ],
    2006 => [ qw( 0109 0224 0508 1106 ) ],
    2007 => [ qw( 0430 0611 1105 1231 ) ],
    2008 => [ qw( 0225 0310 0502 0613 1103 ) ],
    2009 => [ qw( 0109 0309 0511 ) ],
    2010 => [ qw( 0222 0503 0510 0614 1105 ) ],
    2011 => [ qw( 0110 0307 0502 0613 ) ],
    2012 => [ qw( 0109 0309 0430 0507 0508 0611 1105 1231 ) ],
    2013 => [ qw( 0502 0503 0510 ) ],
    2014 => [ qw( 0310 0502 0613 1103 ) ],
    2015 => [ qw( 0109 0309 0504 0511 ) ],
    2016 => [ qw( 0222 0307 0502 0613 ) ],
    2017 => [ qw( 0109 0508 1106 ) ],
);

my %BUSINESS_DAYS_ON_WEEKENDS = (
    2006 => [ qw( 0226 ) ],
    2007 => [ qw( 1229 ) ],
    2008 => [ qw( 0504 0607 ) ],
    2009 => [ qw( 0111 ) ],
    2010 => [ qw( 1113 ) ],
    2012 => [ qw( 0311 0505 ) ],
    2014 => [], # woohoo 
    2015 => [], # woohoo 
);

my %SHORT_BUSINESS_DAYS = (
    2005 => [ qw( 0222 0305 1103 ) ],
    2006 => [ qw( 0222 0307 0506 1103 ) ],
    2007 => [ qw( 0222 0307 0428 0508 0609 ) ],
    2008 => [ qw( 0222 0307 0430 0508 0611 1101 1231 ) ],
    2009 => [ qw( 0430 0508 0611 1103 1231 ) ],
    2010 => [ qw( 0227 0430 0611 1103 1231 ) ],
    2011 => [ qw( 0222 0305 1103 ) ],
    2012 => [ qw( 0222 0307 0428 0512 0609 1229 ) ],
    2013 => [ qw( 0222 0307 0430 0508 0611 1231 ) ],
    2014 => [ qw( 0224 0307 0430 0508 0611 1231 ) ],
    2015 => [ qw( 0430 0508 0611 1103 1231 ) ],
    2016 => [ qw( 0227 0305 1103 ) ],
    2017 => [ qw( 0222 0307 0506 1103 ) ],
);


=head2 is_holiday( $year, $month, $day )

Determine whether this date is a RU holiday. Returns holiday name or undef.

=cut

sub is_holiday {
    my ( $year, $month, $day ) = @_;

    die 'Bad params'  unless $year && $month && $day;

    $_ = '0' . $_  for grep { length == 1 } $month, $day;

    return holidays( $year )->{ $month . $day };
}

=head2 is_ru_holiday( $year, $month, $day )

Alias for is_holiday().

=cut

sub is_ru_holiday {
    is_holiday( @_ );
}

=head2 holidays( $year )

Returns hash ref of all RU holidays in the year.

=cut

my %cache;
sub holidays {
    my $year = shift or die 'Bad year';

    return $cache{ $year }  if $cache{ $year };

    my %holidays = %HOLIDAYS_YEARLY;

    if ( my $spec = $HOLIDAYS_SPECIAL{ $year } ) {
        $holidays{ $_ } = 'Перенос праздничного дня'  for @$spec;
    }

    return $cache{ $year } = \%holidays;
}

=head2 is_business_day( $year, $month, $day )

Returns true if date is a business day in RU taking holidays and weekends into account.

=cut

sub is_business_day {
    my ( $year, $month, $day ) = @_;

    die 'Bad params'  unless $year && $month && $day;

    $_ = '0' . $_  for grep { length == 1 } $month, $day;

    return 0  if is_holiday( $year, $month, $day );

    # check if date is a weekend
    my $t = Time::Piece->strptime( "$year-$month-$day", '%Y-%m-%d' );
    my $wday = $t->day;
    return 1  unless $wday eq 'Sat' || $wday eq 'Sun';

    # check if date is a business day on weekend
    my $ref = $BUSINESS_DAYS_ON_WEEKENDS{ $year } or return 0;

    my $md = $month . $day;
    for ( @$ref ) {
        return 1  if $_ eq $md;
    }

    0;
}

=head2 is_short_business_day( $year, $month, $day )

Returns true if date is a shortened business day in RU.

=cut

sub is_short_business_day {
    my ( $year, $month, $day ) = @_;

    my $short_days = $SHORT_BUSINESS_DAYS{$year};
    return ''  if !$short_days;

    my $date_key = sprintf '%02d%02d', $month, $day;
    return !!grep {$_ eq $date_key} @$short_days;
}



=head1 AUTHOR

Alexander Nalobin, C<< <alexander at nalobin.ru> >>

=cut

1;
