#!/bin/julia
using Base.Filesystem

#= Currently targeting the structure:
rootdir: <artist>
(sub)dirname: <album name> (<date>)
filename: <track number> - <title><untracked extension or nothing>

A "meta" file in a directory contains tab-separated pairs that explicitly specify meta, skipping the parsing from dirname. For example, an "ACDC" directory containing an "ACDC/meta" file containing "artist	AC/DC" line will specify the artist of everything found in the directory to be "AC/DC", not "ACDC".
=#

struct Meta
	artist::Vector{String}
	albumname::Vector{String}
	albumyear::Vector{String}
	trackname::Vector{String}
	tracknum::Vector{String}
end
Meta() = Meta(Vector{String}(), Vector{String}(), Vector{String}(), Vector{String}(), Vector{String}())

"""
    parse_pairfile(path::AbstractString)

Parse a pair file into a Dict.

A pair file consists of lines containing key\tvalue pairs.
"""
function parse_pairfile(path::AbstractString)
	dict = Dict{Symbol, String}()
	for line in readlines(path)
		rmatch = match(r"(\w+)\t(.+)", line)
		dict[Symbol(rmatch.captures[1])] = rmatch.captures[2]
	end
	return dict
end

if isempty(ARGS)
	println("Called with no arguments, assuming current working directory.")
	rootdir = pwd()
else
	rootdir = realpath(ARGS[1])
end
meta = Meta()
# Set the default artist, specified by meta file or deduced from rootdir name otherwise.
pushfirst!(meta.artist, get(parse_pairfile(joinpath(rootdir, "meta")), :artist, basename(rootdir)))
globalmeta = parse_pairfile(joinpath(rootdir, "meta"))

for (path, dirs, files) in walkdir(rootdir)
	println("Entering $path")
	dirmatch = match(r"(.+)\s*\((\d{4})\)", basename(path))
	if dirmatch != nothing
		albumname = dirmatch.captures[1]
		albumyear = dirmatch.captures[2]
	else
		albumname = basename(path)
		albumyear = nothing
	end
	@assert albumname != nothing
	@info("albumname: $albumname")
	for file in files
		fullpath = joinpath(path, file)
		println("Processing $fullpath")
		filematch = match(r"(\d+)\s*-\s*([^\.]+)(?:\..+)?", file)
		if filematch != nothing
			tracknum = filematch.captures[1]
			trackname = filematch.captures[2]
		else
			tracknum = nothing
			trackname = match(r"(.+)(?:\..+)?", file).captures[1]
		end
		converter_args = ["--artist", artist, "--song", trackname, "--album", albumname]
		if albumyear != nothing
			push!(converter_args, "--year", albumyear)
		end
		if tracknum != nothing
			push!(converter_args, "--track", tracknum)
		end
		println.(converter_args)
		run(`id3v2 $converter_args $fullpath`)
	end
end
