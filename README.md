# Film Meta Tool

Tool for managing film scan metadata, focusing on fixing incorrect dates from common film scanners. Particularly useful for scans from Frontier and Noritsu scanners that default to 1988 when the CMOS needs to be replaced.

## Features

- Fix incorrect dates from film scanners
- Batch rename files with sequential numbering
- Set ISO values
- Add copyright information
- Audit directories for suspicious dates
- Handle nested directories
- Preserve original metadata

## Quick Start

### Install Dependencies

```bash
# On Ubuntu/Debian
sudo apt-get install exiftool

# On macOS with Homebrew
brew install exiftool
```

### Install Film Meta Tools

```bash
# Option 1: Copy to your personal bin directory
mkdir -p ~/bin
cp bin/* ~/bin/
chmod +x ~/bin/film-scan-*

# Option 2: Copy to system bin (requires sudo)
sudo cp bin/* /usr/local/bin/
sudo chmod +x /usr/local/bin/film-scan-*
```

### Basic Usage

```bash
# Fix dates and rename files
film-scan-fix ~/Pictures/Roll01 --name "2024_01_portra400"

# Check for suspicious dates
film-scan-audit ~/Pictures/Roll01
```

## Detailed Usage

### Fixing Film Scans

```bash
# Basic usage - renames files and fixes suspicious dates
film-scan-fix ~/Pictures/Roll01 --name "2024_01_portra400"

# Set ISO and copyright
film-scan-fix ~/Pictures/Roll01 \
    --name "2024_01_portra400" \
    --iso 400 \
    --copyright "© Your Name" #Defaults to $DEFAULT_COPYRIGHT env variable.

# Keep original dates (only rename files)
film-scan-fix ~/Pictures/Roll01 --no-date

# Set a specific date
film-scan-fix ~/Pictures/Roll01 --date "2024:01:15 12:00:00"
```

### Auditing Scans

```bash
# Basic scan - shows suspicious files
film-scan-audit ~/Pictures/Roll01

# Verbose mode - shows all files with dates and ISO
film-scan-audit ~/Pictures/Roll01 --verbose

# Check multiple directories
film-scan-audit ~/Pictures/Roll01 ~/Pictures/Roll02

# Check entire photo directory
film-scan-audit ~/Pictures
```

Example output:
```
Analyzing directory: Roll01
Found suspicious file: SCAN_001.JPG (Year: 1988, ISO: 400)
Found suspicious file: SCAN_002.JPG (Year: 1988, ISO: 400)
Directory summary: 2/24 files suspicious

Total image files found: 24
Suspicious files found: 2
```

## Development

### Dependencies

Development requires additional tools:
- `exiftool` - for metadata manipulation
- `ImageMagick` - for creating test images
- `shellcheck` - for linting shell scripts

```bash
# On Ubuntu/Debian
sudo apt-get install exiftool imagemagick shellcheck

# On macOS with Homebrew
brew install exiftool imagemagick shellcheck
```

### Project Structure

```
film-meta-tools/
├── bin/                   # Executable scripts
│   ├── film-scan-fix      # Fix metadata and rename files
│   ├── film-scan-audit    # Analyze dates and report issues
│   └── film-utils.sh      # Shared utilities
├── tests/
│   ├── fixtures/          # Test images
│   ├── test-utils.sh      # Test helpers
│   ├── test-film-scan-fix.sh
│   └── test-film-scan-audit.sh
├── Makefile               # Build and test automation
└── README.md              # This file
```

### Running Tests

```bash
# Run all tests
make test

# Clean up test artifacts
make clean
```

### Troubleshooting

1. **Permission Denied**
```bash
chmod +x bin/film-scan-*
```

2. **Command Not Found**
   - Ensure the scripts are in your PATH
   - Check installation directory is in PATH: `echo $PATH`
   - Restart your terminal after PATH changes

3. **Missing Dependencies**
```bash
# Check exiftool installation
exiftool -ver

# Check ImageMagick installation
magick -version
```

4. **Incorrect Dates**
   - Verify file is a supported format
   - Check current dates: `film-scan-audit --verbose`
   - Try specifying date manually: `film-scan-fix --date "2024:01:15 12:00:00"`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Submit a pull request

### Code Style
- Use shellcheck for linting: `make lint`
- Follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

## License

MIT License - See LICENSE file for details

## Acknowledgments

- Thanks to Phil Harvey for ExifTool
- Inspired by my scanning issues with [Cape Film Supply's](https://capefilmsupply.co.za/) frontier.