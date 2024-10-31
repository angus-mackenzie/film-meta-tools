#!/bin/bash

# Check if required parameters are provided
if [[ -z "$1" ]]; then
  echo "Error: Directory not specified"
  echo "Usage: $0 <directory> [options]"
  echo "Options:"
  echo "  --name <prefix>     Set the filename prefix (defaults to timestamp)"
  echo "  --date <date>       Set the date (defaults to current date)"
  echo "  --no-date          Keep original dates"
  echo "  --iso <value>       Set ISO value (only if not already set)"
  echo "  --copyright <text>  Set copyright (defaults to '© Angus Mackenzie')"
  exit 1
fi

DIRECTORY="$1"
NAME=""
UPDATE_DATE=true
CURRENT_DATE=$(date +"%Y:%m:%d %H:%M:%S")
ISO=""
COPYRIGHT="© Angus Mackenzie"
SUS_YEARS=("1988" "1989" "1990")

# Parse optional parameters
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      NAME="$2"
      shift 2
      ;;
    --date)
      CURRENT_DATE="$2"
      shift 2
      ;;
    --no-date)
      UPDATE_DATE=false
      shift
      ;;
    --iso)
      ISO="$2"
      shift 2
      ;;
    --copyright)
      COPYRIGHT="© $2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Set default prefix to timestamp if none provided
if [[ -z "$NAME" ]]; then
  NAME="roll_$(date +%Y%m%d_%H%M%S)"
fi

# Initialize counter for sequential numbering
COUNT=1

# Process each file in the directory
for file in "$DIRECTORY"/*; do
  # Skip non-image files
  if [[ ! -f "$file" ]]; then
    continue
  fi

  # Get file extension
  EXT="${file##*.}"
  
  # Create new filename with prefix and counter
  NEW_NAME="${NAME}_$(printf "%03d" $COUNT).$EXT"

  # Get the current EXIF year
  EXIF_YEAR=$(exiftool -CreateDate -d '%Y' "$file" | awk -F': ' '{print $2}')
  
  # Base exiftool command with filename and copyright
  EXIFTOOL_CMD="-m -overwrite_original"
  EXIFTOOL_CMD+=" '-FileName=$NEW_NAME'"
  EXIFTOOL_CMD+=" '-copyright=$COPYRIGHT'"
  
  # Add ISO command if specified
  if [[ -n "$ISO" ]]; then
    EXIFTOOL_CMD+=" '-exif:iso=$ISO' -if 'not \$exif:iso'"
  fi
  
  # Check if we should update dates
  if [[ "$UPDATE_DATE" == true && " ${SUS_YEARS[@]} " =~ " ${EXIF_YEAR} " ]]; then
    EXIFTOOL_CMD+=" '-ExifIFD:CreateDate=$CURRENT_DATE'"
    EXIFTOOL_CMD+=" '-ExifIFD:DateTimeOriginal=$CURRENT_DATE'"
    
    # Execute command
    eval "exiftool $EXIFTOOL_CMD '$file'" || {
      echo "Error processing file: $file"
      continue
    }

    echo "Updated file, dates, and metadata: $file -> $NEW_NAME"
  else
    # Execute command without date updates
    eval "exiftool $EXIFTOOL_CMD '$file'" || {
      echo "Error processing file: $file"
      continue
    }
    echo "Renamed file and updated metadata (kept original dates): $file -> $NEW_NAME"
  fi

  ((COUNT++))
done