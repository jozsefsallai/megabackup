# Mega Backup

Shell script for backing up files and MySQL data to a MEGA account. Works on Linux machines (prefered terminal is bash).

## How It Works

The script creates a ZIP archive of the files and folders that you've specified + all the MySQL databases. Once the archive is created, it automatically uploads it to the specified Mega account's root. If there's not enough space, it gradually removes the oldest archives until there is enough space for the new one. When everything's done, it removes all the temporary files it has created on the machine (including the backup archive).

Tested on Debian sid and Ubuntu 18.04.

## Prerequisites

 * [megatools](https://github.com/megous/megatools)
 * zip

Before using the script, make sure to configure your `~/.megarc` properly. See `man megarc` for more details.

## Getting Started

Clone this repository:

```
git clone git@github.com:jozsefsallai/megabackup
```

Create your `paths.txt` file and edit it accordingly.

```
cp paths.example.txt
vi paths.txt
```

Run the script:

```
./backup.sh
```

If that fails, set up the appropriate file permissions.

```
chmod +x backup.sh
./backup.sh
```

You should see the output of each step in your terminal.

*Note: The script was made to primarily work on Debian-based machines. If you use something else (e.g. CentOS, Arch, etc.), you might want to edit the `MYSQL_DEFAULTS_EXTRA_FILE` variable in the `backup.sh` file, depending on the distribution you're using.*

## Automation

You can use `cron` or any similar utility to automate the script execution. Here's a cron entry for every 30 minutes.

```
*/30 * * * * sh /path/to/megabackup/backup.sh >/dev/null 2>&1
```

## License

MIT
