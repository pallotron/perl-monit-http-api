#!/usr/bin/perl

use FindBin;
# load modules from "lib" subdir relative to this script
use lib "$FindBin::RealBin/lib"; 

use Monit::HTTP ':constants';
use Data::Dumper;
use Getopt::Std;
use YAML;

my @hosts = ('all');
my $non_human_output = 0;
my $DEBUG = 0;
my $cfg_file;
my $service = 'all';
my $command = 'status';

# ----------------------------------------------------------------------------
# Print debug message if $DEBUG is true
sub dbg {
    my ($text) = @_;
    print STDERR "[**DEBUG**]\n$text\n" if($DEBUG);
}
# ----------------------------------------------------------------------------


# ----------------------------------------------------------------------------
# Print usage
sub usage {
    use Pod::Usage;
    pod2usage(2);
}
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Parse arguments of scripts
sub parse_opts {

    my (%opts, $error);
    getopts('ho:NDc:', \%opts) or $error = 1;

    @hosts = split ',' , $opts{'o'} if defined $opts{'o'};
    $non_human_output = 1 if defined $opts{'N'};
    $DEBUG = 1 if defined $opts{'D'};
    usage if $error or defined $opts{'h'};
    $command= $ARGV[0] if defined $ARGV[0];  
    $service = $ARGV[1] if defined $ARGV[1];  

    

    dbg ("Config is as follow:\nhosts selected: ".join(",", @hosts)."\n".
        "non_human_output: $non_human_output\n".
        "DEBUG: $DEBUG\n".
        "Service: $service\n".
        "Command: $command\n"
        );
}
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Read YAML configuration file
sub read_cfg {

    my $file;

    if( -r $ENV{'HOME'}."/.mm.conf.yml") { $f = $ENV{'HOME'}."/.mm.conf.yml"; }
    elsif( -r "/etc/mm.conf.yml") { $f = "/etc/mm.conf.yml"; }
    elsif( -r "$FindBin::RealBin/mm.conf.yml") 
        { $f = "$FindBin::RealBin/mm.conf.yml"; }
    
    open (TEST, $f);
    $file .= $_ while(<TEST>);
    dbg "Config file is:\n$file";
    close TEST;
    $cfg_file = Load($file);
    if($DEBUG) {
        dbg ("\$cfg_file data dump is:\n".Dumper $cfg_file);
    }

}
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# MAIN PROGRAM

parse_opts;
read_cfg;

# if the provided hosts are not in configuration files scream
# against the user
foreach my $h (@hosts) {
    my $h2 = { map { $_->{hostname}=>1 } @{$cfg_file->{'hosts'}}};
    if(not exists $h2->{$h} and $hosts[0] ne "all") {
        print STDERR "Host \"$h\" doesn't exist in config file, skipping...\n";
    }
}

# for each host...
foreach my $i (@{$cfg_file->{'hosts'}}) {

    # if the command is list just list this host and go to the next one
    # without actually doing anything else
    if($command eq "list") {
        print "* $i->{hostname}\n";
        next;;
    }

    # if host doesn't exist in config file and we are asking to perform
    # an action across all host just skip silently to the next one
    if( not exists { map { $_ => 1 } @hosts }->{$i->{hostname}} and
        $hosts[0] ne "all") {

        next;

    # if the host we provided as argument of mm exists in mm.conf
    # do the job
    } else {

        my $auth;
        # if password and username are not defined set $auth = 0
        defined $i->{password} and defined $i->{username} ? $auth=0 : $auth=1 ;

        my @services;
        my $hd;

        eval {

            # instanciate a Monit::HTTP:API object 
            $hd = new Monit::HTTP(
                    hostname => $i->{hostname},
                    port     => $i->{port},
                    username => $i->{username},
                    password => $i->{password},
                    use_auth => $auth,
                );

            # get list of all services

            @services = $hd->get_services;

        } or do {
            
            print STDERR $@;
            print "Skipping to next host...\n";
            next;

        };

        dbg (Dumper @services);

        if( $command eq "start" or
            $command eq "stop" or
            $command eq "monitor" or
            $command eq "unmonitor" ) {

            #TODO: loop thru all services, if service is all print all
            # otherwise print only if servicename is eq to the one
            # provided

            foreach my $s (@services) {
                if($service eq "all" or $service eq $s) {
                    $hd->command_run($s, $command);
                }
            }

        } 
        
        if( $command eq "summary" or $command eq "status") {
            #TODO: get status of that command  and populate hashref tree
        }
    }

    
}

#TODO: print result navigating the status hashref tree

__END__

=head 1 NAME

mm - a CLI to manage a cluster of monit daemons

=head1 SYNOPSIS

mm [options] [<command>] all|SERVICE..

    options:
        -h,              show this help message and exit
        -o HOST[,HOST]*  comma separated list of hosts (default: "all")
                         provided hosts must be defined in the config file
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

