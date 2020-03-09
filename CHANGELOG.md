## Unreleased

* Remove `die` function which it turns out isn't universal.
* Minor improvements to sash-err-stack + sash-parse + sash-trap
  - Locks more into bashv4 with specific bashv4 features that
    prevent the need to spawn subshells.
  - Make some scripts a bit easier to read by removing nesting
    branches.
* Introduce "wrap" functions for sash commands so they don't just
  cause your shell to randomly exit, leaving you in an undiagnosed
  state.
* Allow sash to work on windows by adding an option to not check the executable
  bit.

## 1.3.0 (October 14th, 2019)

* Split out trap functionality to: `sash-trap`
* Add Tests for `sash-err-stack`
* Add Tests for `sash-parse`
* Add Tests for `sash-trap`
* Speed up `sash-parse` by multiple times.
* Create: `sash <subcommand>` commands.
* Basic Documentation for: `sash package` in README.
* Add in: `sash time`, which allows seeing how long creating the shell took.

## 1.2.0 - (February 23rd, 2019)

* Don't source `sash-parse.sh` before plugins load as plugins can overwrite that.
* Move `sash-parse.sh` into a `sash-libs` folder.
* Create `sash-utils` for basic utility script for sash directly.
* Use `sash-err-stack` to set error mode for sash, but not ruin any parts of the shell
  caused by error mode being active.
* Use traps to ensure IFS isn't left in a bad state for `sash-parse`/`sash-add`.
* `sash-parse` now depends on `sash-err-stack`
* Finalize `sash-package.sh` which allows you to package up a particular category, or subcategory
  for distribution to others. Signs with keybase, otherwise you need to provide: "--unsafe-no-sign".

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
