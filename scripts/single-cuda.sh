#! /bin/env bash

# Init script variables
input_dir='/data/input'
output_dir='/data/output/mpi-cuda'
# input_files=(psb5.in morphine.in taxol.in valinomycin.in)
input_files=(water.in)

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
    if [[ -f "$file" ]] ; then
        echo "Processing file '$file'."
        { time quick.cuda $file 2> /dev/null ; } 2> "$file.time"
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
