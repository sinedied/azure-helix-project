#!/usr/bin/env bash
##############################################################################
# Usage: ./build.sh
# Builds the project before deployment.
##############################################################################
# THIS FILE IS AUTO-GENERATED, DO NOT EDIT IT MANUALLY!
# If you need to make changes, edit the file `blue.yaml`.
##############################################################################

set -e
cd $(dirname ${BASH_SOURCE[0]})
if [ -f ".settings" ]; then
  source .settings
fi

commit_sha="$(git rev-parse HEAD)"

echo "Building project '${project_name}'..."
cd ..

echo "Building 'helix-function'..."
pushd helix-function

npm ci --production

popd

echo "Build complete for project '${project_name}'."
