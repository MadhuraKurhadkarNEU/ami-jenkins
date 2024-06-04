#!/bin/bash

# Check if commit message is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <commit-message>"
  exit 1
fi

# Assign the commit message to a variable
COMMIT_MESSAGE="$1"

# Function to check if the current branch is the feature branch
is_current_branch_feature() {
  current_branch=$(git symbolic-ref --short HEAD)
  [[ "$current_branch" == "$1" ]]
}

# Function to check if a branch exists
branch_exists() {
  git rev-parse --verify "$1" >/dev/null 2>&1
}

# Function to create or switch to the feature branch
create_or_switch_branch() {
  branch_name="$1"

  if is_current_branch_feature "$branch_name"; then
    echo "Already on branch $branch_name"
  elif branch_exists "$branch_name"; then
    echo "Switching to existing branch $branch_name"
    git checkout "$branch_name"
  else
    echo "Creating and switching to new branch $branch_name"
    git checkout -b "$branch_name"
  fi
}

# Set the feature branch name
feature_branch="feature1"

# Create or switch to the feature branch
create_or_switch_branch "$feature_branch"

# Add all changes to the staging area
git add .

# Commit changes with the provided commit message
git commit -m "$COMMIT_MESSAGE"

# Push the new branch to the origin
git push origin "$feature_branch"

# Prompt user to compare and create a pull request via UI
echo "Please compare and create a pull request for the '$feature_branch' branch on GitHub."
echo "Press any key to continue after the pull request has been merged..."
read -n 1 -s

# Switch to the main branch
git checkout main

# Pull the latest changes from the upstream main branch
git pull upstream main

# Merge the 'feature1' branch into the 'main' branch
git merge "$feature_branch"

# Push the updated main branch to the origin
git push origin main

echo "Workflow completed successfully."
