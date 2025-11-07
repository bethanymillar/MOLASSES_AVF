#!/bin/bash

# Path to the vents file and output directory
VENTS_FILE="./inputs/vent_source/vents_East_B.utm"  # Assuming you have a specific vents file for Auckland
OUTPUT_DIR="./flow_outputs/B/flowB_East"
CSV_CLEANER_SCRIPT="./scripts/convert_to_csv_B.py"
RASTER_CONVERTER_SCRIPT="./scripts/lava_flow_rasterised_B.py"

# Path to the virtual environment directory
VENV_DIR=./molasses_env_B

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# Create the virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
  echo "Virtual environment created at $VENV_DIR"
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Install required packages (make sure your system environment matches venv)
pip install --upgrade pip
pip install numpy==1.23.5 pandas==2.2.3 gdal==3.9.3

# Loop through each vent coordinate in vents_AuckC.utm (Make sure the file exists)
if [ ! -f "$VENTS_FILE" ]; then
  echo "Error: Vents file $VENTS_FILE not found."
  deactivate
  exit 1
fi

while IFS= read -r line; do
  # Extract X and Y coordinates from the vents file
  X=$(echo "$line" | awk '{print $1}')
  Y=$(echo "$line" | awk '{print $2}')
  
  # Update the vents file with current vent coordinates
  echo "$X $Y" > ./inputs/vents_B.utm

  # Run the MOLASSES model and check if it produces an output
  ./bin/molasses_B.ljc ./inputs/molasses_B_E.conf

  # Check if the flowB0 output file exists
  if [ -f "flowB0" ]; then
    # Define CSV output path
    output_csv="$OUTPUT_DIR/flowB_${X}_${Y}.csv"

    # Run the CSV cleaner script to create a clean CSV
    python3 "$CSV_CLEANER_SCRIPT" "flowB0" "$output_csv"

    # Convert the cleaned CSV to a raster file
    output_raster="${output_csv%.csv}.tif"
    python3 "$RASTER_CONVERTER_SCRIPT" "$output_csv" "$output_raster"

    echo "Raster created for $output_csv at $output_raster"
  else
    echo "Error: flowB0 file not found for vent at X:$X, Y:$Y"
  fi

done < "$VENTS_FILE"

# Deactivate the virtual environment
deactivate

echo "Batch conversion completed!"

