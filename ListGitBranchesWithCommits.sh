#!/bin/bash

# Script to list all Git branches and their commit information for a given project directory.

# Function to display usage instructions
usage() {
    echo "Usage: $0 <project_path>"
    echo "Example: $0 /path/to/my/project"
    exit 1
}

# Check if a path is provided
if [ $# -eq 0 ]; then
    echo "Error: No project path provided."
    usage
fi

# Get the project path from the first argument
PROJECT_PATH="$1"

# Validate that the provided path exists
if [ ! -d "$PROJECT_PATH" ]; then
    echo "Error: The provided path '$PROJECT_PATH' does not exist."
    exit 1
fi

# Validate that the provided path is a Git repository
if [ ! -d "$PROJECT_PATH/.git" ]; then
    echo "Error: The provided path '$PROJECT_PATH' is not a Git repository."
    exit 1
fi

# Function to list branches and their commit information
list_branches_with_commits() {
    echo "Fetching Git branch and commit information for project: $PROJECT_PATH"
    echo "----------------------------------------"
    
    # Navigate to the project directory
    cd "$PROJECT_PATH" || exit
    
    # Fetch updates from the remote
    echo "Fetching latest updates from remote..."
    git fetch --all
    echo
    
    # List local branches and their latest commit
    echo "Local Branches and Latest Commits:"
    for branch in $(git branch --list | sed 's/*//'); do
        branch=$(echo "$branch" | xargs) # Trim whitespace
        latest_commit=$(git log -n 1 --pretty=format:"%h - %an, %ar : %s" "$branch")
        echo "  $branch: $latest_commit"
    done
    echo
    
    # List remote branches and their latest commit
    echo "Remote Branches and Latest Commits:"
    for branch in $(git branch -r | grep -v '\->'); do
        branch=$(echo "$branch" | xargs) # Trim whitespace
        latest_commit=$(git log -n 1 --pretty=format:"%h - %an, %ar : %s" "$branch")
        echo "  $branch: $latest_commit"
    done
    echo
    
    # Display commit history for the current branch
    echo "Commit History for Current Branch ($(git branch --show-current)):"
    git log --oneline --graph --decorate -n 10
    echo "----------------------------------------"
}

# Call the function to list branches and their commits
list_branches_with_commits
