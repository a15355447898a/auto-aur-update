cd any-code-appimage
latest_ver=$(curl -s https://api.github.com/repos/anyme123/Any-code/releases/latest | jq -r .tag_name | tr -d 'v')
sed -i "s/pkgver=.*/pkgver=$latest_ver/" PKGBUILD
sudo -u builder updpkgsums
cd -
