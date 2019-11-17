# Sash Libs #

Sash libs is a directory that contains any library that sash itself uses that
is considered general enough as to not be tied to sash. Ideally these plugins
can be used by anyone supporting any platform that Sash does. Feel free to use
this indepdently as their own libraries, and file bugs on them as independent
libs.

The libraries themselves are listed below.

## Sash-Err-Stack ##

`sash-err-stack` is a library for controlling `set -e` state. If
you're a library like sash, you can't just: `set -e`, since that causes
problems for other scripts around you. However, you still want the benefits
`set -e` provides in order to ensure your script doesn't keep running. This
is where `sash-err-stack` fits in.

Dependencies:
  * Sash-Trap

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

Dependencies:
  * Sash-Err-Stack
  * Sash-Trap (dependency of Sash-Err-Stack)

## Sash-Trap ##

`sash-trap` is a library built for "safely-handling" traps. More specifically
built to get around the fact that the `trap` command by default, stomps all
over a command that was previously in trap. Making it impossible, to actually
recursively set traps without everyone knowing how to properly add to a trap.

Dependencies: None
