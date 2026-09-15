# Maintainer: Adrian <adrian@mxlinux.org>
pkgname=mx25-artwork
pkgver=${PKGVER:-26.05.02}
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

    # Mirror every background into wallpapers/ and backgrounds/xfce/, which is
    # what debian/links does (40 entries into each) and what the Fedora spec
    # does. Without this /usr/share/wallpapers holds only the attribution text,
    # and Plasma's wallpaper picker - which reads that directory - shows nothing.
    #
    # Skipped: the xfce directory itself, and the attribution .txt, neither of
    # which debian/links references. Note the Fedora spec skips the attribution
    # file by its old misspelled name; matching on .txt avoids depending on that.
    install -dm755 "${pkgdir}/usr/share/backgrounds/xfce"
    local f base
    for f in "${pkgdir}/usr/share/backgrounds"/*; do
        [ -f "$f" ] || continue
        base=$(basename "$f")
        case "$base" in *.txt) continue ;; esac
        ln -sf "/usr/share/backgrounds/${base}" "${pkgdir}/usr/share/wallpapers/${base}"
        ln -sf "/usr/share/backgrounds/${base}" "${pkgdir}/usr/share/backgrounds/xfce/${base}"
    done
}
