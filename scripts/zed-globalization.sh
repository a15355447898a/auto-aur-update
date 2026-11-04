cd zed-globalization
release_json=$(curl -s https://api.github.com/repos/wenyinos/ZedG/releases/latest)
latest_ver=$(echo "$release_json" | jq -r .tag_name | sed 's/^v//')
cur_ver=$(grep -m1 '^pkgver=' PKGBUILD | cut -d= -f2)
if [ -n "$latest_ver" ] && [ "$latest_ver" != "null" ] && [ "$(vercmp "$latest_ver" "$cur_ver")" = "1" ]; then
  # 上游重建版本时 tag 会变成 v1.26.2.1,但资产文件名仍用上游版本 v1.26.2
  case "$latest_ver" in
    *.*.*.*) asset_ver=${latest_ver%.*} ;;
    *)       asset_ver=$latest_ver ;;
  esac
  base_url="https://github.com/wenyinos/ZedG/releases/download/v${latest_ver}"
  sed -i "s/^pkgver=.*/pkgver=$latest_ver/" PKGBUILD
  sed -i "s/^pkgrel=.*/pkgrel=1/" PKGBUILD
  sed -i "s|^source_x86_64=.*|source_x86_64=(\"$base_url/zedg-zh-cn-linux-x86_64-v$asset_ver.tar.gz\")|" PKGBUILD
  sed -i "s|^source_aarch64=.*|source_aarch64=(\"$base_url/zedg-zh-cn-linux-aarch64-v$asset_ver.tar.gz\")|" PKGBUILD
fi
sudo -u builder updpkgsums
sudo -u builder makepkg --printsrcinfo > .SRCINFO
cd -
