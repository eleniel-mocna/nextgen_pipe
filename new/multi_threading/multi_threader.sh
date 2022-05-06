#!/bin/bash

threads_file="/data/Samuel_workdir/nextgen_pipe/new/multi_threading/available_threads" # TODO

_get_threads(){
    ( flock 200
    available_threads="$(cat "$threads_file")"
    if [ $(("$available_threads"-"$1")) -ge 0 ]; then
        # echo "Wanted: $1; available: $available_threads - GIVEN">&2
        cat>"$threads_file"<<<$(("$available_threads"-"$1"))
        echo 1
    else
        # echo "Wanted: $1; available: $available_threads - FORBIDDEN">&2
        echo 0
    fi
    flock -u 200 )200>"$threads_file.lock"
}

give_back_threads(){
    ( flock 200
    available_threads="$(cat "$threads_file")"
    # echo "Available: $available_threads, updated to $(("$available_threads"+"$1"))"
    cat>"$threads_file"<<<"$(( "$available_threads"+"$1" ))"
    flock -u 200 )200>"$threads_file.lock"
}

# This takes the number of threads as an argument and waits for 
# threads to get available.
# It returns number of threads available for allocation
# (which is min(requested threads, max available threads))
get_threads(){
    n_threads="$1"
    if [ $# -ge 2 ]; then
        timeout="$2"
    else
        timeout=10800 # If for 3 hours there is still not enough threads, try taking all available.
    fi
    current_time=0
    while [ "$(_get_threads "$n_threads")" = 0 ]; do
        sleep 1
        (( current_time+=1 ))
        if [ "$current_time" -ge "$timeout" ] && [ "$n_threads" -gt 1 ]; then
            (( n_threads="$n_threads"-1 ))
        fi
    done
    echo "$n_threads"
}

restore_threads(){
    echo "$1">"$threads_file"
}