# Sash-Err-Stack #

sash-err-stack is a full stack for set error mode. What exactly does that mean?
It means we allow setting error-modes at the function level, depending on your
call-stack you can now have completely different error modes.

Specifically it allows you to say "set error mode for just this one function",
while keeping the global state pristine.

## Supported Architectures ##

* Anything running Bashv4, although bash 3 should work in theory. Nothing is
  bash v4 specific here.

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

That's it! Simply call each one of these functions whenever you want to either
allow errors, or disallow errors for the runtime of your function.

It should be noted: We check for the error mode being correct at the return of
every function. So even if you call a function that messes with the global error
mode, we will set it back before control is returned to your function.

### Notes ###

Sash-Err-Stack depends very, very heavily on the presence of the RETURN trap being
fired. However, by default trap overwrites the entire trap. Meaning if someone else
clears the return trap we're swell out of luck.

If this happens Undefined Behavior will happen, so you should always ensure traps
are properly set, and unset. To help with this, I recommend looking at `sash-trap`.
