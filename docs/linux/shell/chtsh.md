# cht.sh Command Tool

In Linux it can be hard to remember some commands or options and there is a great tool for that. `cht.sh`

For example :

```bash
curl cht.sh/cat
```

```bash
vagrant@ubuntu-focal:~$ curl cht.sh/cat
 cheat.sheets:cat
# POSIX way in which to cat(1); see cat(1posix).
cat -u [FILE_1 [FILE_2] ...]

# Output a file, expanding any escape sequences (default). Using this short
# one-liner let's you view the boot log how it was show at boot-time.
cat /var/log/boot.log

# This is an ever-popular useless use of cat.
cat /etc/passwd | grep '^root'
# The sane way:
grep '^root' /etc/passwd

# If in bash(1), this is often (but not always) a useless use of cat(1).
Buffer=`cat /etc/passwd`
# The sane way:
Buffer=`< /etc/passwd`

 cheat:cat
# To display the contents of a file:
cat <file>

# To display file contents with line numbers
cat -n <file>

# To display file contents with line numbers (blank lines excluded)
cat -b <file>

 tldr:cat
# cat
# Print and concatenate files.
# More information: <https://www.gnu.org/software/coreutils/cat>.

# Print the contents of a file to the standard output:
cat path/to/file

# Concatenate several files into an output file:
cat path/to/file1 path/to/file2 ... > path/to/output_file

# Append several files to an output file:
cat path/to/file1 path/to/file2 ... >> path/to/output_file

# Copy the contents of a file into an output file without buffering:
cat -u /dev/tty12 > /dev/tty13

# Write `stdin` to a file:
cat - > path/to/file
```

You may say, why do you need this when you already have the `man` command in Linux? The most important feature that makes `cht.sh` different is that it explains each option in the simplest and most simple way. It does not require installation.

Here are a few more examples :

```bash
curl cht.sh/tail
```

```bash
vagrant@ubuntu-focal:~$ curl cht.sh/tail
 cheat:tail
# To show the last 10 lines of <file>:
tail <file>

# To show the last <number> lines of <file>:
tail -n <number> <file>

# To show the last lines of <file> starting with <number>:
tail -n +<number> <file>

# To show the last <number> bytes of <file>:
tail -c <number> <file>

# To show the last 10 lines of <file> and to wait for <file> to grow:
tail -f <file>

 tldr:tail
# tail
# Display the last part of a file.
# See also: `head`.
# More information: <https://www.gnu.org/software/coreutils/tail>.

# Show last 'count' lines in file:
tail --lines count path/to/file

# Print a file from a specific line number:
tail --lines +count path/to/file

# Print a specific count of bytes from the end of a given file:
tail --bytes count path/to/file

# Print the last lines of a given file and keep reading file until `Ctrl + C`:
tail --follow path/to/file

# Keep reading file until `Ctrl + C`, even if the file is inaccessible:
tail --retry --follow path/to/file

# Show last 'num' lines in 'file' and refresh every 'n' seconds:
tail --lines count --sleep-interval seconds --follow path/to/file
```

```bash
curl cht.sh/touch
```

```bash
vagrant@ubuntu-focal:~$ curl cht.sh/touch
 cheat:touch
# To change a file's modification time:
touch -d <time> <file>
touch -d 12am <file>
touch -d "yesterday 6am" <file>
touch -d "2 days ago 10:00" <file>
touch -d "tomorrow 04:00" <file>

# To put the timestamp of a file on another:
touch -r <refrence-file> <target-file>

 tldr:touch
# touch
# Create files and set access/modification times.
# More information: <https://manned.org/man/freebsd-13.1/touch>.

# Create specific files:
touch path/to/file1 path/to/file2 ...

# Set the file [a]ccess or [m]odification times to the current one and don't [c]reate file if it doesn't exist:
touch -c -a|m path/to/file1 path/to/file2 ...

# Set the file [t]ime to a specific value and don't [c]reate file if it doesn't exist:
touch -c -t YYYYMMDDHHMM.SS path/to/file1 path/to/file2 ...

# Set the file time of a specific file to the time of anothe[r] file and don't [c]reate file if it doesn't exist:
touch -c -r ~/.emacs path/to/file1 path/to/file2 ...
```