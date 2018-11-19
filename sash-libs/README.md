# Sash Libs #

Sash libs is a directory that contains any library that sash itself uses that
is considered general enough as to not be tied to sash. Ideally these plugins
can be used by anyone supporting any platform that Sash does. Feel free to use
this indepdently as their own libraries, and file bugs on them as independent
libs.

The libraries themselves are listed below.

## Sash-Parse ##

`sash-parse` is a library built for parsing arguments using nothing but bash,
and associative arrays. Sash Parse is meant to be like: "gflags" for bash.
Now you may be saying to yourself "why not just use getopt? It's already
installed on pretty much every distro!" This of course is true, but there are
two real downsides here:

  1. `getopt` does not support long flags on BSD distros. (Only the GNU
    getopt knows how to properly handle these).
  2. the `getopt` interface can be relatively clunky to work with as you
    are required to parse everything out in one switch statement.

All in all `sash-parse` just provides a "more complete" parsing experience,
one you might expect inside of a full blown language (such as Go, Rust, etc.)
