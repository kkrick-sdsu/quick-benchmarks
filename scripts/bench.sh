#! /bin/env bash

# Init script variables
input_dir='/data/input'
output_dir='/data/output/mpi-cuda'
input_files=(psb5 morphine taxol valinomycin)
command='quick.cuda.MPI'
tasks="1 2 4"

# Verify input directory exists
if [[ -d "$input_dir" ]] ; then
    # Move to input directory
    cd $input_dir
else
    # Handle case where input directory doesn't exist
    echo "Error: '$input_dir' does not exist. Stopping execution."
    exit 1
fi

# Process each of the input files
for file in "${input_files[@]}"; do
    # Verify file exists
    if [[ -f "$file.in" ]] ; then
        echo "Processing file '$file'."
        # Check if running quick.MPI or quick.cuda.MPI for running with tasks
        if [[ $command == *"MPI"* ]]; then
            for t in $tasks; do
                mpirun --allow-run-as-root -np $t $command "$file.in"
                mv "$file.out" "$file.$t.out" 
            done
        # Running with quick or quick.CUDA, no need for MPI and tasks
        else
            $command "$file.in"
        fi
    else
        # Handle case where file does not exist
        echo "Warning: '$file' does not exist. Skipping this file."
    fi
done

# Verify output directory exists
if [[ -d "$output_dir" ]] ; then
    # Move output & time files to output directory
    mv *.out $output_dir
    echo "Processing complete. See output at '$output_dir'."
else
    # Handle case where output directory doesn't exist
    echo "Warning: '$output_dir' does not exist. \
    Output and timing files will be left in the input directory '$input_dir'."
fi

# Exit successfully
exit 0
