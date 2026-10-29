#!/bin/bash
set -euo pipefail

cd jayjay-appimage
previous=$(grep -v '^pkgrel=' PKGBUILD)
cur_ver=$(sed -n 's/^pkgver=//p' PKGBUILD)
cur_rel=$(sed -n 's/^pkgrel=//p' PKGBUILD)
# Keep the AUR recipe identical to the one JayJay ships in its own pacman repository.
curl -fsSL --retry 3 https://raw.githubusercontent.com/hewigovens/jayjay/main/dist/arch/PKGBUILD > PKGBUILD
latest_tag=$(curl -fsSL --retry 3 https://api.github.com/repos/hewigovens/jayjay/releases/latest | jq -er '.tag_name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))')
latest_ver=${latest_tag#v}
if [ "$(vercmp "$latest_ver" "$(sed -n 's/^pkgver=//p' PKGBUILD)")" = "1" ]; then
  sed -i -e "s/^pkgver=.*/pkgver=$latest_ver/" -e 's/^pkgrel=.*/pkgrel=1/' PKGBUILD
fi
sudo -u builder updpkgsums

pkgver=$(sed -n 's/^pkgver=//p' PKGBUILD)
if [ "$pkgver" = "$cur_ver" ]; then
  if [ "$(grep -v '^pkgrel=' PKGBUILD)" = "$previous" ]; then
    pkgrel=$cur_rel
  else
    pkgrel=$((cur_rel + 1))
  fi
  sed -i "s/^pkgrel=.*/pkgrel=$pkgrel/" PKGBUILD
fi
sudo -u builder sh -c 'makepkg --printsrcinfo > .SRCINFO'

for arch in x86_64 aarch64; do
  asset="jayjay-gpui-$arch.AppImage"
  published=$(curl -fsSL --retry 3 "https://github.com/hewigovens/jayjay/releases/download/v$pkgver/$asset.sha256")
  read -r expected filename <<< "$published"
  actual=$(awk -v key="sha256sums_$arch" '$1 == key && $2 == "=" { print $3 }' .SRCINFO)
  if [[ ! "$expected" =~ ^[0-9a-f]{64}$ || "$filename" != "$asset" || "$actual" != "$expected" ]]; then
    printf 'Checksum verification failed for %s in v%s: generated %s; published %s\n' "$asset" "$pkgver" "$actual" "$published" >&2
    exit 1
  fi
  printf 'Verified %s against the published checksum for v%s\n' "$asset" "$pkgver"
done
