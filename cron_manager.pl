#!/usr/bin/perl

#Cron job manager for df_remind.pl
#Helps install, remove, and manage cron jobs for disk usage monitoring

use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';

my $script_dir = dirname(abs_path($0));
my $df_script = "$script_dir/df_remind.pl";

my $action = '';
my $interval = '*/15 * * * *';  # Default: every 15 minutes
my $path = '/home';  # Default path to monitor
my $config_file = '';  # Configuration file path
my $help = 0;

# Parse command line arguments
GetOptions(
    'action=s' => \$action,
    'interval=s' => \$interval,
    'path=s' => \$path,
    'config=s' => \$config_file,
    'help|h' => \$help,
) or die "Error in command line arguments\n";

if ($help || !$action) {
    show_help();
    exit 0;
}

if ($action eq 'install') {
    install_cron_job();
} elsif ($action eq 'remove') {
    remove_cron_job();
} elsif ($action eq 'list') {
    list_cron_jobs();
} else {
    print "Error: Unknown action '$action'\n";
    show_help();
    exit 1;
}

sub show_help {
    print "Usage: $0 --action <install|remove|list> [options]\n";
    print "Options:\n";
    print "  --action <action>   Action to perform (install, remove, list)\n";
    print "  --interval <cron>   Cron interval (default: '*/15 * * * *' = every 15 minutes)\n";
    print "  --path <path>       Single path to monitor (default: /home)\n";
    print "  --config <file>     Configuration file with paths to monitor\n";
    print "  --help, -h          Show this help message\n";
    print "\n";
    print "Note: --path and --config are mutually exclusive. Use --config for multiple paths.\n";
    print "\n";
    print "Examples:\n";
    print "  $0 --action install                    # Install with defaults\n";
    print "  $0 --action install --interval '0 */6 * * *' --path /var  # Every 6 hours, monitor /var\n";
    print "  $0 --action install --config paths.conf  # Monitor paths from config file\n";
    print "  $0 --action remove                     # Remove df_remind cron jobs\n";
    print "  $0 --action list                       # List current cron jobs\n";
}

sub install_cron_job {
    # Check if df_remind.pl exists and is executable
    if (!-f $df_script) {
        print "Error: df_remind.pl not found at $df_script\n";
        exit 1;
    }
    
    if (!-x $df_script) {
        print "Error: df_remind.pl is not executable. Run: chmod +x $df_script\n";
        exit 1;
    }
    
    # Validate mutually exclusive options
    if ($config_file && $path ne '/home') {
        print "Error: --path and --config are mutually exclusive\n";
        exit 1;
    }
    
    # Create cron entry
    my $cron_line;
    if ($config_file) {
        # Check if config file exists
        if (!-f $config_file) {
            print "Error: Configuration file $config_file not found\n";
            exit 1;
        }
        $cron_line = "$interval $df_script --config $config_file";
    } else {
        $cron_line = "$interval $df_script --path $path";
    }
    
    # Get current crontab
    my $current_crontab = `crontab -l 2>/dev/null`;
    my $exit_code = $? >> 8;
    
    # Check if our entry already exists
    if ($current_crontab =~ /\Q$df_script\E/) {
        print "Warning: A cron job for df_remind.pl already exists.\n";
        print "Current crontab entries for df_remind.pl:\n";
        my @lines = split /\n/, $current_crontab;
        foreach my $line (@lines) {
            if ($line =~ /\Q$df_script\E/) {
                print "  $line\n";
            }
        }
        print "Use --action remove to remove existing entries first.\n";
        return;
    }
    
    # Add new entry
    my $new_crontab = $current_crontab . "\n# Disk usage monitor\n$cron_line\n";
    
    # Install new crontab
    open(my $cron_pipe, '| crontab -') or die "Cannot open crontab: $!\n";
    print $cron_pipe $new_crontab;
    close($cron_pipe);
    
    if ($? == 0) {
        print "Successfully installed cron job:\n";
        print "  $cron_line\n";
        print "This will run $df_script every time according to the schedule: $interval\n";
        if ($config_file) {
            print "Using configuration file: $config_file\n";
        } else {
            print "Monitoring path: $path\n";
        }
    } else {
        print "Error: Failed to install cron job\n";
        exit 1;
    }
}

sub remove_cron_job {
    # Get current crontab
    my $current_crontab = `crontab -l 2>/dev/null`;
    my $exit_code = $? >> 8;
    
    if ($exit_code != 0) {
        print "No crontab found for current user\n";
        return;
    }
    
    # Remove lines containing df_remind.pl
    my @lines = split /\n/, $current_crontab;
    my @filtered_lines;
    my $removed_count = 0;
    
    foreach my $line (@lines) {
        if ($line =~ /\Q$df_script\E/ || $line =~ /# Disk usage monitor/) {
            print "Removing: $line\n";
            $removed_count++;
        } else {
            push @filtered_lines, $line;
        }
    }
    
    if ($removed_count == 0) {
        print "No cron jobs found for df_remind.pl\n";
        return;
    }
    
    # Install filtered crontab
    my $new_crontab = join("\n", @filtered_lines);
    
    open(my $cron_pipe, '| crontab -') or die "Cannot open crontab: $!\n";
    print $cron_pipe $new_crontab;
    close($cron_pipe);
    
    if ($? == 0) {
        print "Successfully removed $removed_count cron job(s)\n";
    } else {
        print "Error: Failed to update crontab\n";
        exit 1;
    }
}

sub list_cron_jobs {
    my $current_crontab = `crontab -l 2>/dev/null`;
    my $exit_code = $? >> 8;
    
    if ($exit_code != 0) {
        print "No crontab found for current user\n";
        return;
    }
    
    print "Current crontab entries:\n";
    print "=" x 50 . "\n";
    print $current_crontab;
    print "=" x 50 . "\n";
    
    # Highlight df_remind entries
    my @lines = split /\n/, $current_crontab;
    my @df_lines;
    
    foreach my $line (@lines) {
        if ($line =~ /\Q$df_script\E/) {
            push @df_lines, $line;
        }
    }
    
    if (@df_lines) {
        print "\ndf_remind.pl entries:\n";
        foreach my $line (@df_lines) {
            print "  $line\n";
        }
    } else {
        print "\nNo cron jobs found for df_remind.pl\n";
    }
}