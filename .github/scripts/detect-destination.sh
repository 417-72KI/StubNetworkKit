#!/bin/zsh

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "\e[0;31mUsage: $0 [macOS|iOS|tvOS|watchOS]\e[;m"
    exit 1
fi

list_simulator() {
    SIM_RUNTIME=$(xcrun simctl list -j devices available | jq -rc ".devices | with_entries(select(.value | length > 0)) | with_entries(select(.key|contains(\"$1\"))) | keys | max")
    echo "name=$(xcrun simctl list -j devices available | jq -rc ".devices[\"$SIM_RUNTIME\"] | min | .name")"
}

case "$1" in
    "macOS" ) echo "platform=macOS" ;;
    "iOS" ) list_simulator iOS ;;
    "tvOS" ) list_simulator tvOS ;;
    "watchOS" ) list_simulator watchOS ;;
    * ) echo "\e[0;31mInvalid input. \nUsage: $0 [macOS|iOS|tvOS|watchOS]\e[;m"
        exit 1 ;;
esac
