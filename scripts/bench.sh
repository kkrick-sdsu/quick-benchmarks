#!/usr/bin/env bash

# Init script variables
input_dir='/data/input'
output_dir='/data/output/mpi-cuda'
input_files=(psb5 morphine taxol valinomycin)
command='quick.cuda.MPI'
tasks="1 2 4"

# Function to display help message
# Credit: Generated with ChatGPT 3.5 Turbo
display_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help             Display this help message."
    echo "  -i, --input-dir DIR   Set the input directory (default: '/data/input')."
    echo "  -o, --output-dir DIR  Set the output directory (default: '/data/output/mpi-cuda')."
    echo "  -f, --input-files LIST Set a comma-separated list of input files (default: 'psb5,morphine,taxol,valinomycin')."
    echo "  -c, --command CMD     Set the command to execute (default: 'quick.cuda.MPI')."
    echo "  -t, --tasks LIST      Set a space-separated list of tasks (default: '1 2 4')."
    exit 0
}

# Parse command-line arguments
# Credit: Generated with ChatGPT 3.5 Turbo
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--input-dir)
            input_dir="$2"
            shift 2
            ;;
        -o|--output-dir)
            output_dir="$2"
            shift 2
            ;;
        -f|--input-files)
            IFS=',' read -ra input_files <<< "$2"
            shift 2
            ;;
        -c|--command)
            command="$2"
            shift 2
            ;;
        -t|--tasks)
            tasks="$2"
            shift 2
            ;;
        -h|--help)
            display_help
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

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
