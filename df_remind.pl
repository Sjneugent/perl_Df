#!/usr/bin/perl

#Filesystem reporter.
#Run on a cron job and report to email 
#or some other remote service

use Filesys::Df;
use Getopt::Long;
use File::Basename;
use Cwd 'abs_path';

use strict;

#-----------------------------------------------
#Kilobyte to Gigabyte conversion               +
#Usage: my $var = kb_to_gb(1000000);           +
#Returns Gigabyte representation of kilobytes  +
#-----------------------------------------------
sub kb_to_gb  {
  my $kb = shift;
  if(defined($kb)) {
    return ($kb) / ( 1024 * 1024);
  }
}

#-----------------------------------------------------
#Generate human readable text from Df output.        +
#Returns                                             +
#Path                                                +
#Percentage used                                     +
#Blocks Free (Gb)                                    +
#Blocks Used (Gb)                                    +
#Total Blocks (kb)                                   +
#Total Blocks (GB)                                   +
#-----------------------------------------------------
sub generate_hr_text  {
  my $df_output = shift;
  my $df_path = shift;
 
  my $fmt_str = "";
  if(defined($df_output)){
    my $percentage = $df_output->{per};
    my $blocks_free_kb = $df_output->{bfree};
    my $blocks_used_kb = $df_output->{used};
    my $blocks_total_kb = $df_output->{blocks};

    my $blocks_free_gb = kb_to_gb($blocks_free_kb);
    my $blocks_used_gb = kb_to_gb($blocks_used_kb);
    my $blocks_total_gb = kb_to_gb($blocks_total_kb);

   $fmt_str = "Path: $df_path\n" . "Percentage Used: $percentage\%\n" . "Blocks Free: $blocks_free_gb GB\n" . "Blocks Used: $blocks_used_gb GB\n" . "Total Blocks: $blocks_total_gb GB\n";
   return $fmt_str;
  }
}

#---------------------
#Entry point         +
#---------------------

# Default path if none provided
my $default_path = "/home";
my $path_to_check = '';
my $config_file = '';
my $help = 0;

# Parse command line arguments
GetOptions(
    'path=s' => \$path_to_check,
    'config=s' => \$config_file,
    'help|h' => \$help,
) or die "Error in command line arguments\n";

if ($help) {
    print "Usage: $0 [options]\n";
    print "Options:\n";
    print "  --path <path>     Single path to check (default: $default_path)\n";
    print "  --config <file>   Configuration file with paths to check\n";
    print "  --help, -h        Show this help message\n";
    print "\n";
    print "If --config is specified, it will check all paths in the config file.\n";
    print "If neither --path nor --config is specified, it will check $default_path.\n";
    exit 0;
}

my @paths_to_check;

if ($config_file) {
    @paths_to_check = read_config_file($config_file);
    if (!@paths_to_check) {
        print "Error: No valid paths found in config file $config_file\n";
        exit 1;
    }
} elsif ($path_to_check) {
    @paths_to_check = ($path_to_check);
} else {
    @paths_to_check = ($default_path);
}

foreach my $check_path (@paths_to_check) {
    my $path = df($check_path);
    
    if(defined($path))  {
        my $results = generate_hr_text($path, $check_path);
        print $results;
        if (@paths_to_check > 1) {
            print "\n" . "-" x 40 . "\n\n";
        }
    } else {
        print "Error: Could not get disk usage information for $check_path\n";
    }
}

#-----------------------------------------------------
#Read configuration file and return list of paths    +
#-----------------------------------------------------
sub read_config_file {
    my $file = shift;
    my @paths;
    
    if (!-f $file) {
        print "Error: Configuration file $file not found\n";
        return ();
    }
    
    open(my $fh, '<', $file) or do {
        print "Error: Cannot open configuration file $file: $!\n";
        return ();
    };
    
    while (my $line = <$fh>) {
        chomp $line;
        # Skip comments and empty lines
        next if $line =~ /^\s*#/ || $line =~ /^\s*$/;
        
        # Remove leading/trailing whitespace
        $line =~ s/^\s+|\s+$//g;
        
        # Validate path exists
        if (-d $line) {
            push @paths, $line;
        } else {
            print "Warning: Path $line from config file does not exist, skipping\n";
        }
    }
    
    close($fh);
    return @paths;
}
