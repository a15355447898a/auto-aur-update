cd mrrss-appimage
latest_ver=$(curl -s https://api.github.com/repos/WCY-dt/MrRSS/releases/latest | jq -r .tag_name | tr -d 'v')
sed -i "s/pkgver=.*/pkgver=$latest_ver/" PKGBUILD
sudo -u builder updpkgsums
sudo -u builder makepkg --printsrcinfo > .SRCINFO
cd -
