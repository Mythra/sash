# Sash-Utils #

Sash-Utils are a series of utilities specifically built for SASH. These APIs
should not be dependened on outside of sash, as they can change/remove/break at
any point in time without warning.

Below is a description of each file.

## choices.sh ##

Choices.sh is a small wrapper around the choices for sash. Specifically things
like getting multiline input, and choosing from a list of options.

## colors.sh ##

Colors.sh provides some constants for color'd logging.

## dirs.sh ##

Dirs.sh provides a place to hang directory code that doesn't really fit
anywhere else.

## err-stack.sh ##

Err-Stack.sh provides sort of some unique functions. It maintains a "stack"
of functions for allowing to easily ignore: `set -e`, and enforce: `set -e`
for specific functions. The idea is we can provide `set -e` on all of our
bash scripts, but still allow specific functions to enforce it on/off.

After all not every function plays by the same rule.

## sash-utils.sh ##

Sources all of the other scripts.
