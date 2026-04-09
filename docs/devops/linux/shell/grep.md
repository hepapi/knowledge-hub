# grep

`grep` is used to search for a specific string or pattern inside files or command outputs. It is an essential tool for troubleshooting, filtering data, and analyzing log files.

---

### Basic Usage

Search for a specific word in a single file:

```bash title="Basic search"
grep "error" /var/log/syslog
```

### Useful Flags

grep provides a number of options that control every aspect of its behavior. The most widely used options are:

-i - Case-insensitive search: Ignores upper and lower case distinctions.

-r - Search recursively: Searches through all files within a directory and its subdirectories.

-v - Invert match: Displays all lines that do not contain the pattern.

-n - Show line numbers: Displays the line number before each matched line.

Examples by Flag:

=== "-i (Case-insensitive)"

```bash title="Ignore case"
grep -i "error" app.log
```
=== "-r (Recursive)"

```bash title="Search in directory"
grep -r "DB_PASSWORD" /etc/
```
=== "-v (Invert)"

```bash title="Filter out logs"
grep -v "INFO" server.log
```
=== "-n (Line numbers)"

```bash title="Show lines"
grep -n "Exception" error.log
```