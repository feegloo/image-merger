#!/bin/bash

# Get the path to the script's directory
script_dir="$(dirname "$0")"
convert_dir="$script_dir/convert"

# Initialize variables
matrix_type=""
merge_type="vertical"  # Default to vertical merge

# Check for the number of arguments
if [ $# -eq 1 ]; then
  # Parse the matrix configuration argument
  matrix_type="$1"

  # Determine merge type based on matrix configuration
  if [ "$matrix_type" = "-v" ]; then
    merge_type="vertical"
  elif [ "$matrix_type" = "-h" ]; then
    merge_type="horizontal"
  elif [[ $matrix_type =~ ^[0-9]+x[0-9]+$ ]]; then
    merge_type="matrix"
  else
    echo "Invalid matrix configuration. Use -v, -h, or specify the matrix configuration (e.g., 2x2)."
    exit 1
  fi
else
  echo "Usage: $0 [-v | -h | N1xN2]"
  exit 1
fi

# Remove any existing "image.jpeg" in the "convert" directory
if [ -e "$convert_dir/image.jpeg" ]; then
  rm "$convert_dir/image.jpeg"
fi

# Step 1: Get a list of all .jpeg files in the "convert" directory
files=("$convert_dir"/*.jpeg)

# Check if there are any .jpeg files
if [ ${#files[@]} -eq 0 ]; then
  echo "No .jpeg files found in the 'convert' directory."
  exit 1
fi

# Step 2: Extract the creation date from the first .jpeg file
creation_date=$(exiftool -d "%Y:%m:%d %H:%M:%S" -s3 -CreateDate "${files[0]}")

# Step 3: Merge the .jpeg files into "image.jpeg" in the "convert" directory according to the matrix configuration
if [ "$merge_type" = "vertical" ]; then
  convert "${files[@]}" -append "$convert_dir/image.jpeg" > /dev/null 2>&1
elif [ "$merge_type" = "horizontal" ]; then
  convert "${files[@]}" +append "$convert_dir/image.jpeg" > /dev/null 2>&1
elif [ "$merge_type" = "matrix" ]; then
  # Separate the input files into two groups
  first_group=("${files[0]}" "${files[1]}")
  second_group=("${files[2]}" "${files[3]}")

  # Merge horizontally in two steps
  convert "${first_group[@]}" +append "$convert_dir/image1.jpeg" > /dev/null 2>&1
  convert "${second_group[@]}" +append "$convert_dir/image2.jpeg" > /dev/null 2>&1

  # Merge vertically to produce the final "image.jpeg"
  convert "$convert_dir/image1.jpeg" "$convert_dir/image2.jpeg" -append "$convert_dir/image.jpeg" > /dev/null 2>&1

  # Clean up intermediate "image1.jpeg" and "image2.jpeg"
  rm "$convert_dir/image1.jpeg" "$convert_dir/image2.jpeg"
fi

# Set the creation date for "image.jpeg" in the "convert" directory to the date of the first input image
exiftool -TagsFromFile "${files[0]}" -CreateDate="${creation_date}" -overwrite_original "$convert_dir/image.jpeg" > /dev/null 2>&1
