#!/usr/bin/perl

use lib 'lib';
use strict;
use warnings;
use Test::More tests => 1;

use Monit::HTTP::API ':constants';

use Test::Mock::LWP;



my $hd = new Monit::HTTP::API();
$hd->get_services;

$hd = new Monit::HTTP::API();
eval {
    $hd->get_services(55);
} or do {
    like $@, qr{Don't understand this service type};
};

