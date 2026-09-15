#!/bin/bash

# **********************************************************************
# * Copyright (C) 2024-2025 MX Authors
# *
# * Authors: Adrian <adrian@mxlinux.org>
# *          MX Linux <http://mxlinux.org>
# *
# * This file is part of mx25-artwork.
# *
# * mx25-artwork is free software: you can redistribute it and/or modify
# * it under the terms of the GNU General Public License as published by
# * the Free Software Foundation, either version 3 of the License, or
# * (at your option) any later version.
# *
# * mx25-artwork is distributed in the hope that it will be useful,
# * but WITHOUT ANY WARRANTY; without even the implied warranty of
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# * GNU General Public License for more details.
# *
# * You should have received a copy of the GNU General Public License
# * along with mx25-artwork.  If not, see <http://www.gnu.org/licenses/>.
# **********************************************************************/

set -e

# Default values
BUILD_DIR="build"
CLEAN=false
DEBIAN_BUILD=false
ARCH_BUILD=false

fix_background_permissions() {
    # Ensure packaged directories have standard permissions to avoid build warnings.
    if [ -d backgrounds ]; then
        find backgrounds -type d -exec chmod 755 {} +
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --debian)
            DEBIAN_BUILD=true
            shift
            ;;
        --arch)
            ARCH_BUILD=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --clean         Clean build directory before building"
            echo "  --debian        Build Debian package"
            echo "           --arch          Build Arch Linux package"
            echo "  -h, --help      Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Build Debian package
if [ "$DEBIAN_BUILD" = true ]; then
    echo "Building Debian package..."
    fix_background_permissions
    debuild -us -uc

    echo "Creating debs directory and moving debian artifacts..."
    mkdir -p debs
    mv ../*.deb debs/ 2>/dev/null || true
    mv ../*.changes debs/ 2>/dev/null || true
    mv ../*.dsc debs/ 2>/dev/null || true
    mv ../*.tar.* debs/ 2>/dev/null || true
    mv ../*.buildinfo debs/ 2>/dev/null || true
    mv ../*build* debs/ 2>/dev/null || true

    echo "Cleaning build directory and debian artifacts..."
    rm -rf "$BUILD_DIR"
    rm -f debian/*.debhelper.log debian/*.substvars debian/files
    rm -rf debian/.debhelper/ debian/deb-installer/ obj-*/
    rm -f ../*build* ../*.buildinfo 2>/dev/null || true

    echo "Debian package build completed!"
    echo "Debian artifacts moved to debs/ directory"
    exit 0
fi

# Build Arch Linux package
if [ "$ARCH_BUILD" = true ]; then
    echo "Building Arch Linux package..."
    fix_background_permissions

    echo "Running makepkg to build the package..."
    makepkg -f

    echo "Arch Linux package build completed!"
    exit 0
fi

# Clean build directory if requested
if [ "$CLEAN" = true ]; then
    echo "Cleaning build directory and debian artifacts..."
    rm -rf "$BUILD_DIR"
    rm -f debian/*.debhelper.log debian/*.substvars debian/files
    rm -rf debian/.debhelper/ debian/deb-installer/ obj-*/
    rm -f ../*build* ../*.buildinfo 2>/dev/null || true
fi

echo "No build target selected. Use --debian or --arch."
