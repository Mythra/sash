# Sash-Err-Stack #

sash-err-stack is an "error mode function stack", specifically it allows you to
say: "I want you to turn on `set -e` for this one function, and than leave it
at whatever it was previously at".

This also allows you to persist `set -e` across a function even if a function
you call is misbehaved and messes up the error mode.

## Supported Architectures ##

* Anything running Bashv4 or greater.

## API ##

```bash
# __sash_allow_errors()
#
# Modifies Variables:
#  * _sash_global_err_mode_stack
#
# sets the error mode to be off for the runtime of this function.
__sash_allow_errors()

# __sash_guard_errors()
#
# Modifies Variables:
#  * _sash_global_err_mode_stack
#
# sets the error mode to be on for the runtime of this function.
__sash_guard_errors()
```

That's it. Simply call one of these two functions at the beginning of your function,
and we will start enforcing the error mode you requested through the entire body
of this function. (even if a function you call changes it.)

***NOTE: you should not call these multiple times per function.***

### Notes ###

Sash-Err-Stack depends very, very heavily on the presence of the RETURN trap being
fired. However, by default the bash command 'trap' overwrites the entire trap.
Meaning if someone else clears the return trap we're swell out of luck.

When this occurs it is unclear what will happen (e.g. this is: "UB", or
undefined-behaviour). Sash itself will not overwrite anything in the trap,
but merely append. If you need to modify the return trap, without overwriting
it we recommend looking at: `sash-trap` which can help you with this task.
