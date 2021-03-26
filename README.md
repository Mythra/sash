# S.A.S.H. #

Sash is a series of bash v4 scripts built to help users modularize their bashrc.
If you're like me and have often wondered "why is this in my bashrc", or "oh shoot
where did I put this thing in my bashrc".

S.A.S.H. is built on the idea of "categories", and "sub-categories". "Categories"
being overarching categories such as "work"/"home"/"languages"/"utilties", where
sub-categories go within that such as "ruby" within "languages".

sash creates a directory structure under `~/.bash/plugins/`. Specifically:
`~/.bash/plugins/<main_category>/<sub_category>/*.sh`. So although
sash will allow you to create those on your first run, you can make them
manually if you prefer.

There is one "special" category however. This is what's known as the "post" category.
The "post" category ***does not*** have subcategories. Instead relying on the filenames
to identify what they are. The post category is specifically used for when you want to run
a piece of shell code _after_ everything else has run. There are a couple projects that need
this, and this is the "sash" way of handling it. Again we don't want you to ever have to touch
`~/.bashrc`. You should know where to look.

## Installation ##

Installing sash for the first run is easy (the migration will take some time though).
Simply clone this repo:

```
$ git clone https://github.com/Mythra/sash
```

Then add the sash script to your .bashrc (this should be the only thing in there
ideally besides the boilerplate your os adds in):

```
$ echo "source ~/sash/sash.sh" >> ~/.bashrc
```

Then restart your terminal! It will ask you to create some initial overarching
categories if you didn't manually create them first.

## Usage ##

### sash add ###

Whenever you need to add something to your modularized bashrc instead of manually
`mkdir && vim`'ing a file reach for `sash add`:

```bash
$ sash add
Please Choose a Category:
1) /home/<user>/.bash/plugins/utilities
2) /home/<user>/.bash/plugins/work
3) /home/<user>/.bash/plugins/language
#? 1
Please Choose a SubCategory:
1) New
#? 1
Please Enter the New Category Name: test
Please Enter a filename to add this content to (should end in .sh): test.sh
[+] Added, and sourced!
$ cat ~/.bash/plugins/utilities/test/test.sh
# This is a test of sash
# using multiline comments
export SASH_TEST=1
```

This will open two windows inbetween "subcategory", and "filename". One window for you
to type the content you want to add the bashrc, and one for you to type comments
(without the annoying '#' at the beginning of the line for long comments) so you can
know what it is when coming back to it later.

### sash show ###

If you're like me you've probably created a lot of individual files under a specific subcategory.
To the point where you have so many files you don't want to manually cat them all out. Enter `sash show`.
Sash show allows you to get a materialized view of an entire sub category so that way you know exactly what
content is in it.

```bash
$ sash show
Please Choose a Category:
1) /home/<user>/.bash/plugins/utilities
2) /home/<user>/.bash/plugins/work
3) /home/<user>/.bash/plugins/language
#? 1
Please Choose a SubCategory:
1) ./test
#? 1

###############################################################
# Content from: /home/<user>/.bash/plugins/utilities/test/test.sh
###############################################################

# This is an example of
# adding some content to sash with multiple lines
# for testing
export SASH_TEST=1
$ sash show utilities test

###############################################################
# Content from: /home/<user>/.bash/plugins/utilities/test//test.sh
###############################################################

# This is an example of
# adding some content to sash with multiple lines
# for testing
export SASH_TEST=1
```

### sash package ###

sash package is a tool for distributing parts (a category or subcategory) to
other users. Not only that it signs the package using keybase for you so people
can validate that it came from you.

Simply run: `sash package`.

### sash time ###

sash time is a tool for detecting what is taking so long in your shell startup.
sash time simply gives you an overview of how many seconds (more or less) it
took to load each file in your shell.

NOTE: this uses the bash builtin: `$SECONDS` which is techincally not readonly,
if you have an unbehaved shell script it's time + the global time will be
reported incorrectly. Please don't abuse seconds.

Simply run `sash time`, to get a formatted output of the time things to load
down to the second granularity.

### sash_trace ###

If you aren't able to find out where a particular command is executing (or you want to see which
command is taking awhile to execute), you can set `SASH_TRACE=1` in your bashrc before the `source ~/sash/sash.sh`
line. This will turn sash in "debug mode" which prints out every command that is executed, and from which file it's
being execute from.

NOTE: you can use `sash time` to find out what script took how many seconds to get a high level idea. It does
not require opt-in like sash_trace does.
