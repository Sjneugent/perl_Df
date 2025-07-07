2/2/2017 - Updated with Cron Job Support
Simple usage of the perl Filesys::Df module to report on system partitions.
Now includes automated cron job management and configuration file support.

Requirements:
Linux/Unix type system.
Perl
Filesys::Df module from CPAN (install with: sudo apt-get install libfilesys-df-perl)

Files:
- df_remind.pl: Main disk usage monitoring script
- cron_manager.pl: Helper script to manage cron jobs  
- paths.conf: Configuration file for multiple paths to monitor
- CRON_SETUP.md: Detailed setup guide

Initial commit:
kb to gb function
human readable format from df(<Path>) output

New features:
✓ Command line arguments support
✓ Configuration file support for multiple paths
✓ Automated cron job installation/removal
✓ Flexible scheduling options
✓ Executable scripts with proper shebang

Quick Start:
1. Install a cron job: ./cron_manager.pl --action install
2. Monitor multiple paths: ./cron_manager.pl --action install --config paths.conf
3. Remove cron jobs: ./cron_manager.pl --action remove

See CRON_SETUP.md for detailed instructions.

TODO:
Add email functionality
Enhanced logging options


