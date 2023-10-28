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
    echo "Invalid matrix configuration. Use -v, -h, or specify the matrix configuration (e.g., 2x2 or 3x2)."
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

# Check if the files are named numerically, e.g., "1.jpeg", "2.jpeg", and so on
named_files=true
for file in "${files[@]}"; do
  filename=$(basename "$file")
  if ! [[ "$filename" =~ ^[0-9]+\. ]]; then
    named_files=false
    break
  fi
done

# If the files are named numerically, use the order of files for merging
if [ "$named_files" = true ]; then
  sort_files=($(ls -v "${files[@]}"))
else
  # Extract the creation date for each .jpeg file
  creation_dates=()
  for file in "${files[@]}"; do
    creation_date=$(exiftool -d "%Y:%m:%d %H:%M:%S" -s3 -CreateDate "$file")
    creation_dates+=("$creation_date")
  done

  # Sort the files based on creation dates
  IFS=$'\n' sorted=($(paste -d ":" <(echo "${creation_dates[*]}") <(echo "${files[*]}") | sort -t ":" -k1,1))
  unset IFS

  # Separate the sorted files
  sort_files=("${sorted[@]#*:}")
fi

# Step 2: Merge the .jpeg files into "image.jpeg" in the "convert" directory according to the matrix configuration
if [ "$merge_type" = "vertical" ]; then
  convert "${sort_files[@]}" -append "$convert_dir/image.jpeg" > /dev/null 2>&1
elif [ "$merge_type" = "horizontal" ]; then
  convert "${sort_files[@]}" +append "$convert_dir/image.jpeg" > /dev/null 2>&1
elif [ "$merge_type" = "matrix" ]; then
  # Check the number of available files
  num_files=${#sort_files[@]}

  if [ "$matrix_type" = "2x2" ] && [ "$num_files" -eq 4 ]; then
    # Handle a 2x2 matrix
    first_row=("${sort_files[0]}" "${sort_files[1]}")
    second_row=("${sort_files[2]}" "${sort_files[3]}")

    # Merge horizontally in two steps
    convert "${first_row[@]}" +append "$convert_dir/image1.jpeg" > /dev/null 2>&1
    convert "${second_row[@]}" +append "$convert_dir/image2.jpeg" > /dev/null 2>&1

    # Merge vertically to produce the final "image.jpeg"
    convert "$convert_dir/image1.jpeg" "$convert_dir/image2.jpeg" -append "$convert_dir/image.jpeg" > /dev/null 2>&1

    # Clean up intermediate "image1.jpeg" and "image2.jpeg"
    rm "$convert_dir/image1.jpeg" "$convert_dir/image2.jpeg"
  elif [ "$matrix_type" = "3x2" ] && [ "$num_files" -eq 6 ]; then
    # Handle a 3x2 matrix
    first_row=("${sort_files[0]}" "${sort_files[1]}")
    second_row=("${sort_files[2]}" "${sort_files[3]}")
    third_row=("${sort_files[4]}" "${sort_files[5]}")

    # Merge horizontally in three steps
    convert "${first_row[@]}" +append "$convert_dir/image1.jpeg" > /dev/null 2>&1
    convert "${second_row[@]}" +append "$convert_dir/image2.jpeg" > /dev/null 2>&1
    convert "${third_row[@]}" +append "$convert_dir/image3.jpeg" > /dev/null 2>&1

    # Merge vertically to produce the final "image.jpeg"
    convert "$convert_dir/image1.jpeg" "$convert_dir/image2.jpeg" "$convert_dir/image3.jpeg" -append "$convert_dir/image.jpeg" > /dev/null 2>&1

    # Clean up intermediate "image1.jpeg", "image2.jpeg", and "image3.jpeg"
    rm "$convert_dir/image1.jpeg" "$convert_dir/image2.jpeg" "$convert_dir/image3.jpeg"
  else
    echo "Invalid number of files for the specified matrix configuration. Use 2x2 or 3x2 for the respective matrix."
    exit 1
  fi
fi

# Set the creation date for "image.jpeg" in the "convert" directory to the date of the first input image
exiftool -TagsFromFile "${sort_files[0]}" -CreateDate="${creation_dates[0]}" -overwrite_original "$convert_dir/image.jpeg" > /dev/null 2>&1
