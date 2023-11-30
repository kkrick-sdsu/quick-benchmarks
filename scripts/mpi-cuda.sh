#! /bin/env bash

# Init script variables
input_dir='/data/input'
output_dir='/data/output/mpi-cuda'
input_files=(psb5 morphine taxol valinomycin)
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
        for t in $tasks; do
            { time mpirun --allow-run-as-root -np $t quick.cuda.MPI "$file.in" 2> /dev/null ; } 2> "$file.$t.time"
            mv "$file.out" "$file.$t.out" 
        done
    else
        # Handle case where file does not exist
        echo "Warning: '$file' does not exist. Skipping this file."
    fi
done

# Verify output directory exists
if [[ -d "$output_dir" ]] ; then
    # Move output & time files to output directory
    mv *.out $output_dir
    mv *.time $output_dir
    echo "Processing complete. See output at '$output_dir'."
else
    # Handle case where output directory doesn't exist
    echo "Warning: '$output_dir' does not exist. \
    Output and timing files will be left in the input directory '$input_dir'."
fi

# Exit successfully
exit 0
