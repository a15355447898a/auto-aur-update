cd aionui-bin
latest_ver=$(curl -s https://api.github.com/repos/iOfficeAI/AionUi/releases/latest | jq -r .tag_name | tr -d 'v')
sed -i "s/pkgver=.*/pkgver=$latest_ver/" PKGBUILD
sudo -u builder updpkgsums
cd -
