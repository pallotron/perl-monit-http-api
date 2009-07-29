#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Monit::HTTP::API' );
}

diag( "Testing Monit::HTTP::API $Monit::HTTP::API::VERSION, Perl $], $^X" );
