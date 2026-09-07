#!/bin/bash
# Czenglish — instalace XKB a registrace IBus na běžném Linuxu.
set -euo pipefail

if ! command -v python3 >/dev/null 2>&1; then
    echo "Chyba: Nainstalujte Python 3 (balíček python3) a spusťte instalaci znovu." >&2
    exit 1
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
exec python3 "$SCRIPT_DIR/install-linux.py" "$@"
