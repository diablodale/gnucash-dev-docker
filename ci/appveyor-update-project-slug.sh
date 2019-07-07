#!/bin/bash
# method to update the project slug on AppVeyor since it is not possible via UI
# https://github.com/appveyor/ci/issues/725

# Edit these five variables to match your needs
APPVEYOR_API_URL="https://ci.appveyor.com/api"
APPVEYOR_API_KEY="<YOUR API KEY>"
APPVEYOR_ACCOUNT_NAME="<YOUR ACCOUNT NAME>"
APPVEYOR_PROJECT_SLUG_OLD="<OLD PROJECT SLUG>"
APPVEYOR_PROJECT_SLUG_NEW="<NEW PROJECT SLUG>"  # no dots allowed

# Get current project settings
AUTH_HEADER="Authorization: Bearer $APPVEYOR_API_KEY"
CONTENT_TYPE_HEADER="Content-Type: application/json"
PROJECT_SETTINGS_BODY=$( curl -s -H "$AUTH_HEADER" -H "$CONTENT_TYPE_HEADER" "$APPVEYOR_API_URL/projects/$APPVEYOR_ACCOUNT_NAME/$APPVEYOR_PROJECT_SLUG_OLD/settings" )

# Rename project slug
PROJECT_SETTINGS_BODY=$( echo "$PROJECT_SETTINGS_BODY" | jq ".settings" | jq -c ".slug = \"$APPVEYOR_PROJECT_SLUG_NEW\"" )

# Save new project settings
echo "$PROJECT_SETTINGS_BODY" | curl -s -X PUT -H "$AUTH_HEADER" -H "$CONTENT_TYPE_HEADER" -d @- "$APPVEYOR_API_URL/account/$APPVEYOR_ACCOUNT_NAME/projects"
