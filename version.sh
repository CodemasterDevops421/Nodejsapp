#!/bin/bash

# Define colors for better output visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display a banner with the script name
function print_banner() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}=== Semantic Versioning Tag Incrementer ===${NC}"
    echo -e "${BLUE}============================================${NC}"
}

# Function to display usage information
function print_usage() {
    echo -e "${GREEN}Usage: $0 -v [Release|Hotfix|oschange]${NC}"
    echo -e "${GREEN}Example: $0 -v oschange${NC}"
}

# Function to handle incorrect input
function handle_incorrect_input() {
    echo -e "${RED}No version type (https://semver.org/) or incorrect type specified, try: -v [Release, Hotfix, oschange]${NC}"
    print_usage
    exit 1
}

# Function to handle successful tagging
function handle_success() {
    echo -e "${GREEN}Tagged with $NEW_TAG${NC}"
    git tag $NEW_TAG
    git push --tags
    git push
}

# Function to handle case when a tag already exists on this commit
function handle_existing_tag() {
    echo -e "${RED}Already a tag on this commit${NC}"
}

# Print the banner
print_banner

# Get parameters
while getopts v: flag
do
    case "${flag}" in
        v) VERSION=${OPTARG};;
    esac
done

# Fetch the highest tag number, and add v0.1.0 if doesn't exist
git fetch --prune --unshallow 2>/dev/null
CURRENT_VERSION=`git describe --abbrev=0 --tags 2>/dev/null`

if [[ $CURRENT_VERSION == '' ]]
then
    CURRENT_VERSION='v0.1.0'
fi
echo -e "${GREEN}Current Version: $CURRENT_VERSION${NC}"

# Replace . with space so can split into an array
CURRENT_VERSION_PARTS=(${CURRENT_VERSION//./ })

# Get number parts
VNUM1=${CURRENT_VERSION_PARTS[0]}
VNUM2=${CURRENT_VERSION_PARTS[1]}
VNUM3=${CURRENT_VERSION_PARTS[2]}

# Increment version numbers based on input
if [[ $VERSION == 'Release' ]]
then
    VNUM1=v$((VNUM1+1))
elif [[ $VERSION == 'Hotfix' ]]
then
    VNUM2=$((VNUM2+1))
elif [[ $VERSION == 'oschange' ]]
then
    VNUM3=$((VNUM3+1))
else
    handle_incorrect_input
fi

# Create new tag
NEW_TAG="$VNUM1.$VNUM2.$VNUM3"
echo -e "${GREEN}($VERSION) updating $CURRENT_VERSION to $NEW_TAG${NC}"

# Get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

# Only tag if no tag already (also check NEEDS_TAG here)
if [ -z "$NEEDS_TAG" ]; then
    handle_success
else
    handle_existing_tag
fi

echo ::set-output name=git-tag::$NEW_TAG

exit 0

