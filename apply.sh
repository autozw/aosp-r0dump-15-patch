#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s --check|--apply /path/to/aosp-root\n' "$0" >&2
  exit 2
}

[[ $# -eq 2 ]] || usage
mode=$1
target=$2
[[ $mode == --check || $mode == --apply ]] || usage
[[ -f $target/build/envsetup.sh && -d $target/art && -d $target/frameworks/base && -d $target/libcore ]] || {
  printf 'Not an AOSP source root: %s\n' "$target" >&2
  exit 2
}

package_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
patch=$package_dir/r0dump-aosp15-raven-fusion.patch

(
  cd "$package_dir"
  sha256sum --check --quiet SHA256SUMS
)

if [[ -e $target/packages/apps/R0dumpManager/Android.bp ]]; then
  printf 'R0dumpManager already exists in %s; inspect this source tree before applying.\n' "$target" >&2
  exit 1
fi

(
  cd "$target"
  git apply --check --whitespace=nowarn "$patch"
  if [[ $mode == --apply ]]; then
    git apply --whitespace=nowarn "$patch"
  fi
)

if [[ $mode == --apply ]]; then
  printf 'Applied the complete R0DUMP Fusion patch to %s\n' "$target"
else
  printf 'Patch can be applied to %s\n' "$target"
fi
