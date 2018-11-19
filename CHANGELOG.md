## 1.X - Unreleased

* Don't source `sash-parse.sh` before plugins load as plugins can overwrite that.
* Move `sash-parse.sh` into a `sash-libs` folder.

## 1.1.1 (November 5th, 2018)

* Don't spawn subshells when not needed.
* Switch to `#!/usr/bin/env bash` shebang, to properly reference bash on Mac OS X hosts.
* Source sash utilities before loading plugin code.
* Source sash commands after `post` section, so functions can't be overwritten by plugins.
* Add `sash-parse.sh` which allows for parsing arguments without using `getopt` which if different
  for bsd/gnu.
* Add in first iteration of: `sash-package.sh` which allows you to package up a particular category,
  or subcategory for distribution to others. Includes checking for secrets.

## 1.1.0 (October 15th, 2018)

* Add Postload section.
* Add `SASH_LOADING` flag for scripts to detct when sash is the loader.
* Fix no files in a directory causing output.
* Respect Executable Bit.

## 1.0.0 (Feburary 28th, 2018)

* Initial Release of SASH.

