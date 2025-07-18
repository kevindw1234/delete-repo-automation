#!/bin/bash

# GitHub credentials
GITHUB_USERNAME="-lpkevin"
GITHUB_TOKEN=""
ORG_NAME=""
SEARCH_PREFIX=""  # Change this to your required prefix

# API URL to list repositories
LIST_REPOS_URL="https://api.github.com/orgs/$ORG_NAME/repos?per_page=100"

# Fetch all repositories (handling pagination)
echo "🔍 Fetching repositories from: $LIST_REPOS_URL"
repo_list=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" "$LIST_REPOS_URL")

# Extract repo names that start with the given prefix (case-insensitive)
repos=$(echo "$repo_list" | jq -r '.[].name' | grep -iE "^${SEARCH_PREFIX}.*")

# Check if any repositories match
if [[ -z "$repos" ]]; then
    echo "❌ No repositories found starting with '$SEARCH_PREFIX'."
    exit 1
fi

# Delete each matched repository
for REPO_NAME in $repos; do
    DELETE_REPO_URL="https://api.github.com/repos/$ORG_NAME/$REPO_NAME"
    echo "🗑 Deleting repository: $REPO_NAME..."

    response=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" "$DELETE_REPO_URL")

    # Check response status
    if [ "$response" -eq 204 ]; then
        echo "✅ Deleted repository: $REPO_NAME"
    elif [ "$response" -eq 404 ]; then
        echo "❌ Repository not found: $REPO_NAME"
    else
        echo "⚠️ Failed to delete: $REPO_NAME (HTTP $response)"
    fi
done
