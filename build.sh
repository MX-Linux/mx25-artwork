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
FEDORA_BUILD=false

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
        --fedora)
            FEDORA_BUILD=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --clean         Clean build directory before building"
            echo "  --debian        Build Debian package"
            echo "  --arch          Build Arch Linux package"
            echo "  --fedora        Build Fedora RPM package (requires podman)"
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

# Build Fedora RPM package
if [ "$FEDORA_BUILD" = true ]; then
    echo "Building Fedora RPM package..."

    # Check podman availability
    if ! command -v podman &> /dev/null; then
        echo "Error: podman is required for Fedora builds. Install with: sudo apt install podman"
        exit 1
    fi

    SPEC="mx25-artwork.spec"
    PKGNAME="mx25-artwork"
    VERSION="${PKGVER:-25.09.03}"

    echo "Creating Fedora build container..."

    # Ensure fedora-build container exists
    if ! podman ps -a --format '{{.Names}}' | grep -q '^fedora-build$'; then
        podman run -d --name fedora-build --entrypoint /bin/bash \
            registry.fedoraproject.org/fedora:44 \
            -c "sleep infinity"
        podman exec -u 0 fedora-build dnf install -y \
            'dnf-command(builddep)' rpmdevtools rpm-build
        podman exec fedora-build bash -c 'mkdir -p ~/rpmbuild/{SOURCES,SPECS,SRPMS,RPMS}'
    fi

    # Create source tarball from git
    echo "Creating source tarball..."
    git archive --format=tar.gz --prefix="${PKGNAME}/" HEAD \
        -o "/tmp/${PKGNAME}-${VERSION}.tar.gz"

    # Copy to container
    podman cp "/tmp/${PKGNAME}-${VERSION}.tar.gz" \
        fedora-build:/root/rpmbuild/SOURCES/
    podman cp "$SPEC" fedora-build:/root/rpmbuild/SPECS/

    # Build
    echo "Building RPM..."
    podman exec fedora-build bash -c \
        "cd ~/rpmbuild/SPECS && rpmbuild -ba ${SPEC}"

    # Collect results
    mkdir -p "${BUILD_DIR}"
    podman cp fedora-build:/root/rpmbuild/RPMS/ "${BUILD_DIR}/"
    podman cp fedora-build:/root/rpmbuild/SRPMS/ "${BUILD_DIR}/"

    echo "Fedora RPM build completed!"
    echo "RPMs saved to ${BUILD_DIR}/RPMS/ and ${BUILD_DIR}/SRPMS/"
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

echo "No build target selected. Use --debian, --arch, or --fedora."
