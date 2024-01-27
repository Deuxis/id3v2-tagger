# id3v2-tagger
Simple Julia script for generating id3v2 tags from directory structure and filenames.

# Disclaimer
I created this script a couple of years ago for a family member and in a way akin to how one would create a bash script for a similar purpose - quick and dirty.
It worked for me, but I basically treated it only to "the happy path". Please do exercise caution and read through what it does;
it won't `rm -rf --no-preserve-root /`, but it **will** override the pre-existing id3v2 metadata if given the chance.
If you come upon any fixes and improvements, feel free to make a PR or an Issue.

## Usage
The main script is `updatemeta.jl`. (The `resync.jl` is just a thin wrapper over rsync, allowing some directory contents to be skipped.)
```sh
$ ./updatemeta.jl "<root directory for given artist>"
```

It uses a three-level structure:

root directory: `<artist>`

subdirectory: `<album name> (<optional year>)`

filename: `<optional track number> - <title><untracked extension or nothing>`

A "meta" file in the root directory, if existent, should contain tab-separated pairs that explicitly specify metadata, skipping the parsing from dirname.
For example, an "ACDC" directory containing a "meta" file containing an `artist<tab>AC/DC` line will specify the artist of everything found in the directory to be "AC/DC", not "ACDC".

## Requirements:
### updatemeta.jl
- Julia (tested with 1.0, but everything from 0.7 and up should work fine)
- The `id3v2` command-line utility
### resync.jl
- `rsync`

# Installing:
You can make the script accessible from anywhere by name like any other commandline utility by creating a symbolic link in any PATH directory pointing to the script. Or, you know, just drop it into /usr/bin/, I'm not your mom.

Example:
```sh
$ ln -s "<path to cloned repo>/updatemeta.jl" "~/.local/bin/<chosen name>"
```
