%global pkg_name mx25-artwork

Name:           %{pkg_name}
Version:        25.09.03
Release:        1%{?dist}
Summary:        Default wallpaper backgrounds for MX25

License:        GPL-3.0-or-later
URL:            https://mxlinux.org
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch

BuildRequires:  coreutils

%description
Default wallpaper and background images for MX Linux 25 (Xfce edition).
Provides a collection of background images installed to /usr/share/backgrounds/
and /usr/share/wallpapers/ with Xfce-compatible symlinks under
backgrounds/xfce/.

%prep
%autosetup -n %{name}

%install
# Target directories
mkdir -p %{buildroot}%{_datadir}/backgrounds/xfce
mkdir -p %{buildroot}%{_datadir}/wallpapers

# Copy backgrounds
cp -a backgrounds/. %{buildroot}%{_datadir}/backgrounds/

# Copy wallpapers (attribution file)
cp -a wallpapers/. %{buildroot}%{_datadir}/wallpapers/

# Create default25.png from Maturity.png
cp %{buildroot}%{_datadir}/backgrounds/Maturity.png \
   %{buildroot}%{_datadir}/backgrounds/default25.png

# Symlink every background into wallpapers/ (matching debian/links)
for f in %{buildroot}%{_datadir}/backgrounds/*; do
    base=$(basename "$f")
    [ "$base" = "xfce" ] && continue
    case "$base" in *.txt) continue ;; esac
    ln -s "/usr/share/backgrounds/$base" "%{buildroot}%{_datadir}/wallpapers/$base"
done

# Symlink every background into backgrounds/xfce/ (Xfce compat, matching debian/links)
for f in %{buildroot}%{_datadir}/backgrounds/*; do
    base=$(basename "$f")
    [ "$base" = "xfce" ] && continue
    case "$base" in *.txt) continue ;; esac
    ln -s "/usr/share/backgrounds/$base" "%{buildroot}%{_datadir}/backgrounds/xfce/$base"
done

%post
# Recover default25.png if it was removed (matches debian/postinst behaviour)
if [ ! -e "%{_datadir}/backgrounds/default25.png" ]; then
    cp "%{_datadir}/backgrounds/Maturity.png" "%{_datadir}/backgrounds/default25.png"
fi

%files
%doc README.md
%dir %{_datadir}/backgrounds
%{_datadir}/backgrounds/*.jpg
%{_datadir}/backgrounds/*.png
%{_datadir}/backgrounds/mx25-wallpapers-attribution.txt
%dir %{_datadir}/backgrounds/xfce
%{_datadir}/backgrounds/xfce/*
%dir %{_datadir}/wallpapers
%{_datadir}/wallpapers/*

%changelog
* Sat Jun 20 2026 Adrian <adrian@mxlinux.org> - 25.09.03-1
- Initial Fedora RPM packaging for mx25-artwork
