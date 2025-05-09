
#!/bin/bash

set -e

# === Usage Function ===
print_help() {
cat << EOF
Usage: $(basename "$0") []--lib-dir <path> [--dry-run]

Options:
  --lib-dir <path>   Required. Path to directory containing Git repositories to add as submodules.
  --dry-run          Optional. Show what would be done without making changes.
  --help             Show this help message.

Example:
  ./add-submodules.sh --lib-dir libs
  ./add-submodules.sh --lib-dir libs --dry-run
EOF
}

# === Parse CLI Args ===
LIB_DIR=""
DRY_RUN=0

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --lib-dir)
            LIB_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            print_help
            exit 1
            ;;
    esac
done

# === Validate lib dir ===
if [[ -z "$LIB_DIR" ]]; then
    echo "❌ You must provide --lib-dir <path>"
    print_help
    exit 1
fi

if [[ ! -d "$LIB_DIR" ]]; then
    echo "❌ Directory does not exist: $LIB_DIR"
    exit 1
fi

echo "🔍 Scanning '$LIB_DIR' for Git repositories..."

# === Loop through subdirectories ===
for dir in "$LIB_DIR"/*; do
    if [[ -d "$dir/.git" ]]; then
        repo_name=$(basename "$dir")
        echo "📦 Found repo: $repo_name"

        # Get remote URL
        repo_url=$(git -C "$dir" config --get remote.origin.url)

        if [[ -z "$repo_url" ]]; then
            echo "⚠️  No remote.origin.url for $repo_name. Skipping."
            continue
        fi

        if [[ $DRY_RUN -eq 1 ]]; then
            echo "🧪 Dry-run: would add submodule $repo_name from $repo_url"
            continue
        fi

        echo "🔧 Moving existing dir to ${dir}_backup"
        mv "$dir" "${dir}_backup"

        echo "➕ Adding submodule: $repo_name"
        git submodule add "$repo_url" "$dir"

        echo "✅ Submodule added: $repo_name"
    fi
done

echo "🎉 All eligible submodules processed."
