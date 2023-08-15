##  nohup and & 
**Ampersand (&)**

The ampersand (`&`) is an operator that is used to send the execution of a command to the background.

**Syntax:**

``[command] &``

For example, the command ``sleep 5 &`` will start the sleep command in the background. You can then run other commands without having to wait for the sleep command to finish.

**The nohup command**

The `nohup` command is used to run a command in the background without any interruption, even when the terminal session is closed.

**Syntax:**

``nohup [command]``

For example, the command ``nohup sleep 5 &`` will start the sleep command in the background and will continue to run even if you close the terminal session.

## Difference between `nohup` and `&`

The `nohup` and `&` commands are both used to run commands in the background. However, there are some key differences between the two commands.

* **`nohup` prevents the command from being interrupted by the `HUP` signal, even if the terminal session is closed.** The `HUP` signal is typically sent to a process when the terminal session is closed. This can cause the process to stop running. However, the `nohup` command catches the `HUP` signal and ignores it, so that the command continues to run even after the terminal session is closed.
* **`&` does not prevent the command from being interrupted by the `HUP` signal.** If you run a command with the `&` operator and then close the terminal session, the command will stop running.

Differences between the `nohup` and `&` commands:

|  | `nohup` | `&` |
|---|---|---|
| Prevents `HUP` signal | Yes | No |
| Redirects output to file | Yes | No |
| Suitable for | Running commands that need to continue running even after the terminal session is closed | Running commands that don't need to continue running after the terminal session is closed |
