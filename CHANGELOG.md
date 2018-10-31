## 1.1.1 (Unreleased)

* Don't spawn subshells when not needed.
* Switch to `#!/usr/bin/env bash` shebang, to properly reference bash on Mac OS X hosts.
* Source sash utilities before loading plugin code.
* Source sash commands after `post` section, so functions can't be overwritten by plugins.
* Add `sash-parse.sh` which allows for parsing arguments without using `getopt` which if different
  for bsd/gnu.

## 1.1.0 (October 15th, 2018)

* Add Postload section.
* Add `SASH_LOADING` flag for scripts to detct when sash is the loader.
* Fix no files in a directory causing output.
* Respect Executable Bit.

## 1.0.0 (Feburary 28th, 2018)

* Initial Release of SASH.

