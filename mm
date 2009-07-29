#!/usr/bin/perl

use FindBin;
# load modules from "lib" subdir relative to this script
use lib "$FindBin::RealBin/lib"; 

use Monit::HTTP::API ':constants';
use Data::Dumper;

my $hd = new Monit::HTTP::API(username => 'admin', password => 'monit');
my @s = $hd->get_services(TYPE_PROCESS);
$hd->command_run($s[0], "monitor");

