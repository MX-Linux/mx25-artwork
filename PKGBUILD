# Maintainer: Adrian <adrian@mxlinux.org>
pkgname=mx25-artwork
pkgver=${PKGVER:-25.09.03}
pkgrel=1
pkgdesc="Default wallpaper backgrounds for MX25"
arch=('any')
url="https://mxlinux.org"
license=('GPL3')
depends=()
makedepends=()
source=()
sha256sums=()

package() {
    cd "${startdir}"

    install -dm755 "${pkgdir}/usr/share/backgrounds"
    install -dm755 "${pkgdir}/usr/share/wallpapers"

    cp -a backgrounds/. "${pkgdir}/usr/share/backgrounds/"
    cp -a wallpapers/. "${pkgdir}/usr/share/wallpapers/"

    # Create default25.png as copy of Maturity.png
    cp "${pkgdir}/usr/share/backgrounds/Maturity.png" "${pkgdir}/usr/share/backgrounds/default25.png"

    # Create symlink in wallpapers directory
    ln -s "/usr/share/backgrounds/default25.png" "${pkgdir}/usr/share/wallpapers/default25.png"
}
