#!/bin/env bash

# Credit to ChatGPT 3.5-turbo for assistance on using functions and recursively traversing the given directory

directory=$1

# Function to extract platform from filepath
get_platform() {
    local filepath=$1
    if echo "$filepath" | grep -q "/expanse/"; then
        echo "expanse"
    elif echo "$filepath" | grep -q "/nrp/"; then
        echo "nrp"
    else
        echo "unknown"
    fi
}

# Function to process a file
process_file() {
    file=$1
    gpu_type=$(cat $file | grep "CUDA DEVICE NAME" -m 1 | cut -d ":" -f 2)
    gpu_count=$(cat $file | grep "CUDA ENABLED DEVICES" -m 1 | cut -d ":" -f 2)
    scf_time=$(cat $file | grep "TOTAL SCF TIME" -m 1 | cut -d "=" -f 2 | cut -d "(" -f 1)
    gradient_time=$(cat $file | grep "TOTAL GRADIENT TIME" -m 1 | cut -d "=" -f 2 | cut -d "(" -f 1)
    total_time=$(cat $file | grep "TOTAL TIME" -m 1 | cut -d "=" -f 2)

    molecule=$(echo "$file" | awk -F/ '{print $NF}' | cut -d. -f1)
    gpu_type_pretty=$(echo "$gpu_type" | tr ' ' '-' | sed 's/^-//')
    system=$(get_platform "$file")

    echo "$gpu_type_pretty,$gpu_count,TRUE,$molecule,$scf_time,$gradient_time,$total_time,$system" | sed 's/ //g'
}

# Recursive function to process files in the directory
process_directory() {
    local dir=$1
    local has_files=false

    for file in "$dir"/*.*.out; do
        if [ -f "$file" ]; then
            process_file "$file"
            has_files=true
        fi
    done

    if [ "$has_files" = false ]; then
        for subdir in "$dir"/*/; do
            if [ -d "$subdir" ]; then
                process_directory "$subdir"
            fi
        done
    fi
}

# Start processing the directory
echo "gpu_type,gpu_count,containerized,molecule,scf_time,gradient_time,total_time,system"
process_directory "$directory"