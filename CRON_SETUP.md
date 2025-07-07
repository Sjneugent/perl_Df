# Disk Usage Monitor - Cron Setup Guide

This guide explains how to set up the disk usage monitor to run automatically through cron jobs.

## Files

- `df_remind.pl` - Main disk usage monitoring script
- `cron_manager.pl` - Helper script to manage cron jobs
- `paths.conf` - Configuration file for multiple paths to monitor

## Quick Start

1. **Install a basic cron job** (monitors /home every 15 minutes):
   ```bash
   ./cron_manager.pl --action install
   ```

2. **Install with custom interval** (monitors /var every 6 hours):
   ```bash
   ./cron_manager.pl --action install --interval '0 */6 * * *' --path /var
   ```

3. **Install with configuration file** (monitors multiple paths from paths.conf):
   ```bash
   ./cron_manager.pl --action install --config paths.conf --interval '0 */1 * * *'
   ```

4. **List current cron jobs**:
   ```bash
   ./cron_manager.pl --action list
   ```

5. **Remove all df_remind cron jobs**:
   ```bash
   ./cron_manager.pl --action remove
   ```

## Manual Usage

You can also run the monitoring script manually:

```bash
# Monitor single path
./df_remind.pl --path /home

# Monitor multiple paths from config file
./df_remind.pl --config paths.conf

# Show help
./df_remind.pl --help
```

## Configuration File (paths.conf)

Edit `paths.conf` to customize which paths to monitor:

```
# Configuration file for df_remind.pl
# List paths to monitor, one per line
# Lines starting with # are comments

/home
/var
/tmp
/
# Add your custom paths:
# /data
# /backup
```

## Cron Interval Examples

- `*/15 * * * *` - Every 15 minutes
- `0 */6 * * *` - Every 6 hours at minute 0
- `0 9 * * 1` - Every Monday at 9 AM
- `0 0 * * *` - Every day at midnight
- `0 0 * * 0` - Every Sunday at midnight

## Output

The script outputs disk usage information in this format:

```
Path: /home
Percentage Used: 62%
Blocks Free: 27.22 GB
Blocks Used: 44.39 GB
Total Blocks: 71.61 GB
```

When monitoring multiple paths, each path is separated by a line of dashes.

## Troubleshooting

1. **Permission denied**: Make sure scripts are executable:
   ```bash
   chmod +x df_remind.pl cron_manager.pl
   ```

2. **Module not found**: Install the required Perl module:
   ```bash
   sudo apt-get install libfilesys-df-perl
   # or
   cpan -i Filesys::Df
   ```

3. **Cron not working**: Check system logs:
   ```bash
   sudo tail -f /var/log/syslog | grep CRON
   ```

4. **Path doesn't exist**: The script will warn about non-existent paths and skip them.

## Integration with Email

To receive email reports, you can redirect the output:

```bash
./cron_manager.pl --action remove
# Install with email redirection (requires mail command)
(crontab -l; echo "0 */6 * * * /path/to/df_remind.pl --config paths.conf | mail -s 'Disk Usage Report' user@example.com") | crontab -
```

Or modify the script to use an email module for more advanced email functionality.