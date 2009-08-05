#!/usr/bin/perl

use FindBin;
# load modules from "lib" subdir relative to this script
use lib "$FindBin::RealBin/lib"; 
use Monit::HTTP::API ':constants';

my @hosts = ('all');
my $non_human_output = 0;
my $DEBUG = 0;
my $cfg_file;

sub dbg {
    my ($text) = @_;
    print STDERR "[**DEBUG**]\n$text\n" if($DEBUG);
}

sub usage {
    use Pod::Usage;
    pod2usage(2);
}

sub parse_opts {

    use Getopt::Std;
    my (%opts, $error);
    getopts('ho:NDc:', \%opts) or $error = 1;

    @hosts = split ',' , $opts{'o'} if defined $opts{'o'};
    $non_human_output = 1 if defined $opts{'N'};
    $DEBUG = 1 if defined $opts{'D'};
    usage if $error or defined $opts{'h'};
}

sub read_cfg {

    use YAML;
    my $file;

    if( -r $ENV{'HOME'}."/.mm.conf.yml") { $f = $ENV{'HOME'}."/.mm.conf.yml"; }
    elsif( -r "/etc/mm.conf.yml") { $f = "/etc/mm.conf.yml"; }
    elsif( -r "$FindBin::RealBin/mm.conf.yml") { $f = "$FindBin::RealBin/mm.conf.yml"; }
    
    open (TEST, $f);
    $file .= $_ while(<TEST>);
    dbg "Config file is:\n$file";
    close TEST;
    my $cfg_file = Load($file);
    if($DEBUG) {
        use Data::Dumper; 
        dbg ("\$cfg_file data dump is:\n".Dumper $cfg_file);
    }
}



# MAIN

parse_opts;
read_cfg;

__END__

=head 1 NAME

mm - a CLI to manage a cluster of monit daemons

=head1 SYNOPSIS

mm [options] [<command>] all|SERVICE..

    options:
        -h,              show this help message and exit
        -o HOST[,HOST]*  comma separated list of hosts (default: "all")
        -N               output for non-humans
        -D,              debug output
        -c,              configuration file (default: ~/.mm.conf.yml)
                         mm will look also in these location in order of priority:
                            - ~/.mm.conf.yml
                            - /etc/mm.conf.yml
                            - /path/of/mm/mm.conf.yml

    command:

        status    - print status if all services
        summary   - service status groupped by service
        start     - start service(s)
        stop      - stop service(s)
        monitor   - monitor service(s)
        unmonitor - unmonitor service(s)
        list      - list configured hosts

=head1 DESCRIPTION

=head1 SEE ALSO

=head1 AUTHOR

Angelo "pallotron" Failla - pallotron at freaknet.org

=head1 COPYRIGHT

=cut

