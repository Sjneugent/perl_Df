#Filesystem reporter.
#Run on a cron job and report to email 
#or some other remote service
#
#
#
#
use Filesys::Df;

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
my $path = df("/home");

if(defined($path))  {
  my $results = generate_hr_text($path, "/home");
  print $results;
}
