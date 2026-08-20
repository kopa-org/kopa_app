#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 /path/to/archive.xcarchive-or-dsyms-directory" >&2
  exit 64
fi

archive_or_dsyms="$1"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/.." && pwd)"
google_service_info="$project_root/ios/Runner/GoogleService-Info.plist"
pods_root="${PODS_ROOT:-$project_root/ios/Pods}"
upload_symbols="$pods_root/FirebaseCrashlytics/upload-symbols"

if [[ ! -d "$archive_or_dsyms" ]]; then
  echo "dSYM source directory not found: $archive_or_dsyms" >&2
  exit 66
fi

if [[ ! -x "$upload_symbols" ]]; then
  echo "FirebaseCrashlytics/upload-symbols not found: $upload_symbols" >&2
  echo "Run 'pod install' from kopa_app/ first." >&2
  exit 69
fi

if [[ ! -f "$google_service_info" ]]; then
  echo "GoogleService-Info.plist not found: $google_service_info" >&2
  exit 66
fi

dsyms_root="$archive_or_dsyms"
if [[ -d "$archive_or_dsyms/dSYMs" ]]; then
  dsyms_root="$archive_or_dsyms/dSYMs"
fi

found_dsym=false
while IFS= read -r -d '' dsym; do
  found_dsym=true
  echo "Uploading $(basename "$dsym")"
  "$upload_symbols" -gsp "$google_service_info" -p ios "$dsym"
done < <(find "$dsyms_root" -type d -name '*.dSYM' -print0)

if [[ "$found_dsym" != true ]]; then
  echo "No .dSYM bundles found under: $dsyms_root" >&2
  exit 66
fi

echo "Finished uploading dSYMs from: $dsyms_root"
