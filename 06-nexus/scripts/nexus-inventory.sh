#!/usr/bin/env bash
#
# nexus-inventory.sh
# Lists every component stored in each hosted repository of a Nexus registry.
#
# Usage:
#   export NEXUS_URL="http://32.196.216.219:8081"
#   export NEXUS_AUTH="admin:yourpassword"
#   ./nexus-inventory.sh
#
# Credentials come from an environment variable so the password never
# sits in the command line or in this file.

set -euo pipefail

# Read config from the environment, with a sensible default for the URL.
NEXUS_URL="${NEXUS_URL:-http://32.196.216.219:8081}"
NEXUS_AUTH="${NEXUS_AUTH:?Set NEXUS_AUTH='user:password' before running}"

echo "==================================================="
echo " Nexus Registry Inventory"
echo " $NEXUS_URL"
echo " $(date)"
echo "==================================================="
echo

# Step 1: ask the API for all repositories, keep only the hosted ones
# (hosted = the shelves that hold OUR own artifacts).
hosted_repos=$(curl -s -u "$NEXUS_AUTH" \
  "$NEXUS_URL/service/rest/v1/repositories" \
  | jq -r '.[] | select(.type=="hosted") | .name')

# Step 2: for each hosted repo, list the components inside it.
for repo in $hosted_repos; do
  echo "### Repository: $repo"

  # Ask the API for the components in this repo.
  response=$(curl -s -u "$NEXUS_AUTH" \
    "$NEXUS_URL/service/rest/v1/components?repository=$repo")

  # Count them.
  count=$(echo "$response" | jq '.items | length')

  if [ "$count" -eq 0 ]; then
    echo "   (empty)"
  else
    # Print each component as: name  version  format
    echo "$response" | jq -r '.items[] | "   - \(.name)  v\(.version)  [\(.format)]"'
  fi
  echo
done

echo "==================================================="
echo " Inventory complete."
echo "==================================================="
