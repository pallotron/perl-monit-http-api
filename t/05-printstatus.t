
use lib 'lib';
use strict;
use warnings;

use Test::More qw(no_plan);
use Test::MockModule;
use Monit::HTTP ':constants';

my $xml = q{<?xml version="1.0" encoding="ISO-8859-1"?>
<monit>
    <server>
        <incarnation>1249406340</incarnation>
        <version>4.8.1</version>
        <uptime>941058</uptime>
        <httpd>
            <address></address>
            <port>2812</port>
            <ssl>0</ssl>
        </httpd>
    </server>
    <service type="3">
        <collected>1250347245</collected>
        <name>ushare</name>
        <status>0</status>
        <monitor>1</monitor>
        <group></group>
        <pid>6513</pid>
        <ppid>1</ppid>
        <uptime>2204</uptime>
        <children>0</children>
        <memory>
            <kilobyte>4892</kilobyte>
            <kilobytetotal>4892</kilobytetotal>
            <percent>1.0</percent>
            <percenttotal>1.0</percenttotal>
        </memory>
        <cpu>
            <percent>1.8</percent>
            <percenttotal>1.8</percenttotal>
        </cpu>
    </service>
    <service type="5">
        <collected>1250347245</collected>
        <name>localhost</name>
        <status>0</status>
        <monitor>1</monitor>
        <group></group>
        <load>
            <avg01>0.04</avg01>
            <avg05>0.01</avg05>
            <avg15>0.00</avg15>
        </load>
        <cpu>
            <user>0.7</user>
            <system>1.2</system>
            <wait>0.0</wait>
        </cpu>
        <memory>
            <kilobyte>46052</kilobyte>
            <percent>9.5</percent>
        </memory>
    </service>
</monit>
};

eval {

    my $lwp = Test::MockModule->new( 'LWP::UserAgent' );
    $lwp->mock( request =>
        sub {
            # Return a hand crafted HTTP::Response object
            my $response = HTTP::Response->new;
            $response->code(200);
            $response->content($xml);
            return $response; }
        );
    my $hd = Monit::HTTP->new();
    my @services = $hd->get_services;

    is($hd->_get_xml, $xml);

    is($services[0], 'ushare');
    is($services[1], 'localhost');

    my $status = $hd->service_status($services[0]);
    is($status->{name}, 'ushare');
    is($status->{host}, 'localhost');

    $status = $hd->service_status($services[1]);
    is($status->{name}, 'localhost');
    is($status->{host}, 'localhost');
} or do { print $@ };

