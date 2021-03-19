#!/bin/julia
source = ARGS[1]
target = ARGS[2]
excepts = Set(readlines(joinpath(target, "excepts")))
for member in readdir(source)
    if !(member in excepts)
        run(`rsync -ur $(joinpath(source, member)) $target`)
    end
end
