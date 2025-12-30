cd orca-note-appimage
latest_ver=$(curl -s https://api.github.com/repos/sethyuan/orca-note/releases/latest | jq -r .tag_name | tr -d 'v')
sed -i "s/pkgver=.*/pkgver=$latest_ver/" PKGBUILD
sudo -u builder updpkgsums
sudo -u builder makepkg --printsrcinfo > .SRCINFO
cd -
