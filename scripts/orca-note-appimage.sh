cd orca-note-appimage
latest_ver=$(curl -s https://api.github.com/repos/sethyuan/orca-note/releases/latest | jq -r .tag_name | tr -d 'v')
cur_ver=$(grep -m1 '^pkgver=' PKGBUILD | cut -d= -f2)
if [ "$(vercmp "$latest_ver" "$cur_ver")" = "1" ]; then
  sed -i "s/^pkgver=.*/pkgver=$latest_ver/" PKGBUILD
fi
sudo -u builder updpkgsums
sudo -u builder makepkg --printsrcinfo > .SRCINFO
cd -
