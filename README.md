# S.A.S.H. #

Sash is a series of bash v4 scripts built to help users modularize their bashrc.
If you're like me and have often wondered "why is this in my bashrc", or "oh shoot
where did I put this thing in my bashrc".

S.A.S.H. is built on the idea of "categories", and "sub-categories". "Categories"
being overarching categories such as "work"/"home"/"languages"/"utilties", where
sub-categories go within that such as "ruby" within "languages".

sash creates a directory structure under `~/.bash/plugins/`. Specifically:
`~/.bash/categories/<main_category>/<sub_category>/*.sh`. So although
sash will allow you to create those on your first run, you can make them
manually if you prefer.

## Installation ##

Installing sash for the first run is easy (the migration will take some time though).
Simply clone this repo:

```
$ git clone https://github.com/SecurityInsanity/sash
```

Then add the sash script to your .bashrc (this should be the only thing in there
ideally besides the boilerplate your os adds in):

```
$ echo "source ~/sash/sash.sh" >> ~/.bashrc
```

Then restart your terminal! It will ask you to create some initial overarching
categories if you didn't manually create them first.

## Usage ##

### sash_add ###

Whenever you need to add something to your modularized bashrc instead of manually
`mkdir && vim`'ing a file reach for `sash_add`:

```bash
ecoan@kappa:~$ . ~/.bash/sash-add.sh 
ecoan@kappa:~$ sash_add
Please Choose a Category: 
1) /home/CORP.INSTRUCTURE.COM/ecoan/.bash/plugins/utilities
2) /home/CORP.INSTRUCTURE.COM/ecoan/.bash/plugins/work
3) /home/CORP.INSTRUCTURE.COM/ecoan/.bash/plugins/language
#? 1
Please Choose a SubCategory:
1) New
#? 1
Please Enter the New Category Name: test
Please Enter a filename to add this content to (should end in .sh): test.sh
[+] Added, and sourced!
ecoan@kappa:~$ cat ~/.bash/plugins/utilities/test/test.sh 
# This is a test of sash
# using multiline comments
export SASH_TEST=1
```

This will open two windows inbetween "subcategory", and "filename". One window for you
to type the content you want to add the bashrc, and one for you to type comments 
(without the annoying '#' at the beginning of the line for long comments) so you can
know what it is when coming back to it later.

### sash_show ###

If you're like me you've probably created a lot of individual files under a specific subcategory.
To the point where you have so many files you don't want to manually cat them all out. Enter sash_show.
Sash show allows you to get a materialized view of an entire sub category so that way you know exactly what
content is in it.

```bash
ecoan@kappa:~$ sash_show
Please Choose a Category:
1) /home/CORP.INSTRUCTURE.COM/ecoan/.bash/plugins/utilities
2) /home/CORP.INSTRUCTURE.COM/ecoan/.bash/plugins/work
3) /home/CORP.INSTRUCTURE.COM/ecoan/.bash/plugins/language
#? 1
Please Choose a SubCategory:
1) ./test
#? 1

###############################################################
# Content from: /home/CORP.INSTRUCTURE.COM/ecoan/.bash/plugins/utilities/test/test.sh
###############################################################

# This is an example of
# adding some content to sash with multiple lines
# for testing
export SASH_TEST=1
ecoan@kappa:~$ sash_show utilities/test

###############################################################
# Content from: /home/CORP.INSTRUCTURE.COM/ecoan/.bash/plugins/utilities/test//test.sh
###############################################################

# This is an example of
# adding some content to sash with multiple lines
# for testing
export SASH_TEST=1
```


### sash_trace ###

If you aren't able to find out where a particular command is executing (or you want to see which
command is taking awhile to execute), you can set `SASH_TRACE=1` in your bashrc before the `source ~/sash/sash.sh`
line. This will turn sash in "debug mode" which prints out every command that is executed, and from which file it's
being execute from.

