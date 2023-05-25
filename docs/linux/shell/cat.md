# cat

- **Description**: Concatenate files and print on the standard output. Can be used to create a file from the standard input.


This would display the contents of the file in the terminal window.

**Options**

The `cat` command provides several options that can be used to modify its behavior. Here are some of the most useful options:

- `-n`: Shows line numbers in the output.
- `-e`: Shows end-of-line characters as "$".
- `-t`: Shows tab characters as "^I".
- `-v`: Shows non-printable characters as "^M".
- `-s`: Squeezes consecutive empty lines into a single line.
- `-E`: Prints a "$" character at the end of each line.

**Heredoc (Here Document)**


The `heredoc` (Here Document) is a type of redirection that allows you to pass multiple lines of input to a command.

The basic syntax for `heredoc` looks like this:

```bash
cat << LimitString
  text...
LimitString
```

Here, LimitString is any string you choose, and text... is the text you want to pass to the command.


**Inline file creation with redirection**

Same thing above applies here and it saves you from creating a file and then editing it.

```bash
cat << EOF > newfile.txt
This is line 1.
This is line 2.
EOF
```

This command will create `newfile.txt` file with the two lines of text.
