# Sash-Trap #

sash-trap gives you the ability to "safely" add to traps, recursively. the
`trap` command ends up overwriting everything which can be quite unpleasent
when you're being called from a script that needs traps
(and you have to respect their traps).

sash-trap works around that by automatically detecting previously set traps,
and "safely" adding to them by seperating commands with: `;` (even if the
user didn't add one themselves.)

## Supported Architectures ##

* Anything running Bashv4 or greater.

## API ##

```bash
# _sash_get_trapped_text(signal: String)
#
# Modifies Variables: None
#
# parses trap output to get you the command for a signal.
_sash_get_trapped_text()

# _sash_set_trapped_text(command: String, signal: String)
#
# Modifies Variables: None
#
# Wrapper around the trap command, properly respecting empty strings.
_sash_set_trapped_text()

# _sash_safe_add_to_trap(command: String, signal: String)
#
# Modifies Variables: None
#
# safely adds a command to a trap.
#
# NOTE: command should not end with a: `;`
_sash_safe_add_to_trap()
```

That's it! Nothing complex. Just the signal you want to add too,
and the command you want to add. Note: If you plan on removing
it later. Simply grab the original trapped text with:
`_sash_get_trapped_text` before calling `_sash_safe_add_to_trap`.

E.g. something like:

```
to_restore=$(_sash_get_trapped_text "SIGINT")
_sash_safe_add_to_trap "printf '%s' 'sigint hit'" "SIGINT"
echo "$(trap -p SIGINT)"
_sash_set_trapped_text "$to_restore" "SIGINT"
echo "$(trap -p SIGINT)"
```
