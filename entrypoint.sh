#!/usr/bin/env bash

julia --project -e 'using Pkg; Pkg.instantiate();'
julia --project src/rest.jl
