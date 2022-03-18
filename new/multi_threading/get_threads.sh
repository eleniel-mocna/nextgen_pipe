#!/bin/bash

threads_file="/data/Samuel_workdir/nextgen_pipe/new/multi_threading/available_threads"

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
    cat>"$threads_file"<<<"$(("$available_threads"+"$1"))"
    flock -u 200 )200>"$threads_file.lock"
}

do_something(){
    echo "$1: This is doing something..."
    sleep 1
    echo "$1: This has done something!"
}

# This takes the number of threads as an argument and waits for 
# threads to get available.
# It returns number of threads available for allocation
# (which is min(requested threads, max available threads))
get_threads(){
    :
}
a=(1 2 3 4 5)
for i in "${a[@]}"; do
    {
        while [ "$(_get_threads "$i")" = 0 ]; do
            sleep 1
        done
        do_something "$i"
        give_back_threads "$i"
    }&
done
wait
echo "Remaining threads:"
cat "$threads_file"