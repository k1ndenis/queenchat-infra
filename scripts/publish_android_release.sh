#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 APK_PATH VERSION_CODE VERSION_NAME [MINIMUM_VERSION_CODE] [MANDATORY] [CHANGELOG_FILE]" >&2
  exit 64
fi

apk_path=$1
version_code=$2
version_name=$3
minimum_version_code=${4:-$version_code}
mandatory=${5:-false}
changelog_file=${6:-}
project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
releases_dir="$project_root/releases"

case "$version_code:$minimum_version_code" in
  *[!0-9:]* | :* | *::*) echo "Version codes must be positive integers" >&2; exit 64 ;;
esac
if [ "$version_code" -lt 1 ] || [ "$minimum_version_code" -lt 1 ] || [ "$minimum_version_code" -gt "$version_code" ]; then
  echo "minimum_version_code must be between 1 and version_code" >&2; exit 64
fi
if [ "$mandatory" != true ] && [ "$mandatory" != false ]; then
  echo "MANDATORY must be true or false" >&2; exit 64
fi
if [ ! -f "$apk_path" ]; then echo "APK not found: $apk_path" >&2; exit 66; fi
case "$version_name" in *[!0-9.]* | .* | *.) echo "VERSION_NAME must be numeric semantic form (for example 1.2.0)" >&2; exit 64;; esac

filename="queenchat-$version_name.apk"
destination="$releases_dir/$filename"
if [ -e "$destination" ]; then
  echo "Refusing to replace immutable versioned artifact: $destination" >&2; exit 73
fi

sha256=$(sha256sum "$apk_path" | awk '{print $1}')
size_bytes=$(stat -c '%s' "$apk_path")
changelog_json='[]'
command -v jq >/dev/null || { echo "jq is required" >&2; exit 69; }
if [ -n "$changelog_file" ]; then
  [ -f "$changelog_file" ] || { echo "Changelog file not found" >&2; exit 66; }
  changelog_json=$(jq -Rsc 'split("\n") | map(select(length > 0))' "$changelog_file")
fi

mkdir -p "$releases_dir"
tmp_apk=$(mktemp "$releases_dir/.${filename}.XXXXXX")
tmp_json=$(mktemp "$releases_dir/.android_release.json.XXXXXX")
trap 'rm -f "$tmp_apk" "$tmp_json"' EXIT
install -m 0644 "$apk_path" "$tmp_apk"
mv -n "$tmp_apk" "$destination"
jq -n \
  --arg version_name "$version_name" --arg apk_url "https://queenchat.ru/downloads/$filename" \
  --arg sha256 "$sha256" --argjson version_code "$version_code" --argjson minimum_version_code "$minimum_version_code" \
  --argjson mandatory "$mandatory" --argjson size_bytes "$size_bytes" --argjson changelog "$changelog_json" \
  --arg published_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{platform:"android",version_code:$version_code,version_name:$version_name,minimum_version_code:$minimum_version_code,mandatory:$mandatory,apk_url:$apk_url,sha256:$sha256,size_bytes:$size_bytes,changelog:$changelog,published_at:$published_at}' > "$tmp_json"
mv -f "$tmp_json" "$releases_dir/android_release.json"
trap - EXIT
echo "Published $filename (versionCode=$version_code, sha256=$sha256)"
