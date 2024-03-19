##  jobs, bg, and fg

### jobs

The `jobs` command will list all jobs on the system; active, stopped, or otherwise.

#### Example usage:

1.Create a job with using

``` sleep 500 &```

and stop it with ```ctrl + z```. 
   
2.List all the jobs with the command : ``` jobs```

You will see that you have a single stopped job identified by the job number [1].

Other options to know for this command include:

* ```-l``` - list PIDs in addition to default info
* ```-n``` - list only processes that have changed since the last notification
* ```-p``` - list PIDs only
* ```-r``` - show only running jobs
* ```-s``` - show only stopped jobs

### Background

The `bg` command restarts a suspended job, and runs it in the background.

``` bg [JOB_SPEC] ```

**Where JOB_SPEC can be one of the following:**

* `%n`: where `n` is the job number.
* `%abc`: refers to a job started by a command beginning with `abc`.
* `%?abc`: refers to a job started by a command containing `abc`.
* `%-`: specifies the previous job.

### Foreground

The `fg` command switches a job running in the background into the foreground.

```fg [JOB_SPEC]```

**NOTE:** If no `JOB_SPEC` is provided, `bg` and `fg` operate on the **current job**.

For example, if you have two jobs running in the background, and you run the command `bg`, the job that was most recently started will be brought to the foreground.

You can also use the `%` character to specify a job by its job number, or by a partial command name.
