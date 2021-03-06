# Sash-Parse #

sash-parse is a full CLI argument parser built in bash. Meant to be
a rather simplistic parser that feels famaliar to an end user. This was
originally built because Mac OS-X "getopt" does not support "long" flags
(e.g. flags that begin with: `--`). Not to mention getopt is generally
clunky to work with.

An example of all the flag types we support with sash-parse are below:

* `-a` - Short Flag Toggle
* `-a 10` - Short Flag With Arg
* `-a "my apples are cool"` - Short Flag with spaced string
* `-a=10` - Short Flag using Equals with Arg
* `-a="my apples are cool"` - Short Flag using equals with spaced string
* `--apples` - Long Flag Toggle
* `--apples 10` - Long Flag Toggle
* `--apples "my apples are cool"` - Long Flag with spaced string
* `--apples=10` - Long flag with equals
* `--apples="my apples are cool"` - Long flag with equals, and spaced string.

Not to mention sash-parse also supports "STDIN" text which is text that appears after
all flags. So for example:

```bash
$ ARR=("a|apples")
$ __sash_parse_args "-a=test $(echo "sup")" "${ARR[@]}"
$ echo "${__sash_parse_results[__STDIN]}"
sup
```

***NOTE: multiline text within the __STDIN field
is likely to break. We recommend you just have the user give you a path to a
file that you can then read yourself.***

***NOTE: if you need to support an extra arg type please file an issue.***

## Supported Architectures ##

* Anything running Bashv4 or greater.

## API ##

```bash
# __sash_parse_args(to_parse: String, flags: Array<String>) -> Int
#
# Modifies Variables:
#   * __sash_parse_results
#
# Parses the arguments you need to parse, and writes results as an associative array with the name: "__sash_parse_results".
# Use the return value to check if there was an error (non-zero value).
# All results are written using the "long-name" of the flag.
#
# Error Codes:
#   0 - No Error
#   1 - Flag Provided was invalid in some way.
#   2 - Subset of error code 1, flag was duplicated.
#   3 - User Spacing Error.
#   4 - Got arg when expecting value.
#   5 - Unknown Argument
__sash_parse_args()
```

An actual example:

```bash
$ ARR=("a|apples" "b|bacon" "c|choco" "d|dark-choco" "e|eclair" "flags" "going" "home" "in" "j|jackets")
$ __sash_parse_args "-a -b 10 -c \"is good\" -d=hey -e=\"a value with spaces\" --flags --going 10 --home \"or are they\" --in=10 --jackets=\"possibly maybe\"" "${ARR[@]}"
$ echo "${!__sash_parse_results[@]}"
flags jackets apples eclair in going choco home __STDIN bacon dark-choco
$ echo "${__sash_parse_results[flags]}"
0
$ echo "${__sash_parse_results[jackets]}"
possibly maybe
$ echo "${__sash_parse_results[apples]}"
0
$ echo "${__sash_parse_results[eclair]}"
a value with spaces
$ echo "${__sash_parse_results[in]}"
10
$ echo "${__sash_parse_results[going]}"
10
$ echo "${__sash_parse_results[choco]}"
is good
$ echo "${__sash_parse_results[home]}"
or are they
$ echo "${__sash_parse_results[__STDIN]}"

$ echo "${__sash_parse_results[bacon]}"
10
$ echo "${__sash_parse_results[dark-choco]}"
hey
```

### Performance Note ###

It should be noted sash-parse _attempts_ to execute at a reasonable speed
(less than half a second for running the input above in a subshell, and
checking the results of variables).

It does this _most_ of the time, and most of the time is under 300ms for this
input. However bash has been known to make this number highly fluctuate. We've
seen execution times of: < 100ms to ~620ms.

If you need specific performance with bash (for what I don't know), this
probably isn't the most ideal script for you. Though feel free to reach out
about it. I'd be super curious what set of circumstances led you needing
fast executing bash, and not being able to use anything else.
