
#!/bin/bash

base_dir=$(dirname "$0")
cd "$base_dir"

set -e

swift package update
