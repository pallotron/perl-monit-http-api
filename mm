#!/usr/bin/perl

use FindBin;
# load modules from "lib" subdir relative to this script
use lib "$FindBin::RealBin/lib"; 

use Monit::HTTP::API ':constants';

my $hd = new Monit::HTTP::API(hostname => 'localhost', username => 'admin', password => 'monit', use_auth => 1);

my @s;
eval {
    @s = $hd->get_services(TYPE_PROCESS);
    $hd->command_run($s[0], ACTION_START);
} or do {
    print $@;
};



