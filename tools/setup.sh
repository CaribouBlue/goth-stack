#!/bin/bash

PRIMARY_COLOR=93

# Print each command before executing it (for debugging purposes)
# set -x

# Trap Ctrl+C (SIGINT) and exit the script gracefully
trap "echo '\nOk byeeeeeeeeeeeeeeeee......'; exit 0" SIGINT

clear

if ! command -v gum &>/dev/null; then
    echo "gum could not be found. Installing gum..."
    go install github.com/charmbracelet/gum@latest
    if [ $? -ne 0 ]; then
        echo "\nFailed to setup script."
        exit 1
    fi
fi

clear

STYLED_GOTH=$(gum style --foreground 0 --bold "GoTH")

export GUM_INPUT_CURSOR_FOREGROUND=$PRIMARY_COLOR
export GUM_INPUT_PROMPT_FOREGROUND=$PRIMARY_COLOR
export GUM_CONFIRM_PROMPT_FOREGROUND=$PRIMARY_COLOR
export GUM_CONFIRM_SELECTED_FOREGROUND=0
export GUM_CONFIRM_SELECTED_BACKGROUND=$PRIMARY_COLOR
export GUM_CONFIRM_UNSELECTED_FOREGROUND=15
export GUM_CONFIRM_UNSELECTED_BACKGROUND=15
export GUM_SPIN_SPINNER_FOREGROUND=$PRIMARY_COLOR

gum style \
    --foreground $PRIMARY_COLOR --border-foreground $PRIMARY_COLOR --border double \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    "~~ Welcome to $STYLED_GOTH $(gum style --foreground $PRIMARY_COLOR "Stack ~~")"

sleep 2
clear

if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file from .env.example"
else
    echo "Using existing .env file"
fi

source .env
if [ $? -ne 0 ]; then
    echo "\nFailed to load .env file."
    exit 1
fi

sleep 1
clear

if [ -z "$PROJECT_NAME" ]; then
    echo "What's your project name?"

    while [ -z "$PROJECT_NAME" ]; do
        PROJECT_NAME=$(gum input --placeholder "Enter your project name")
    done

    echo "PROJECT_NAME=$PROJECT_NAME" >>.env
fi

clear

if [ -z "$MODULE_PATH" ]; then
    gum confirm "Do you want to use \"$PROJECT_NAME\" as the module path? (https://go.dev/ref/mod#module-path)" && {
        MODULE_PATH=$PROJECT_NAME
    } || {
        echo "What's your module path?"

        while [ -z "$MODULE_PATH" ]; do
            MODULE_PATH=$(gum input)
        done
    }
    echo "MODULE_PATH=$MODULE_PATH" >>.env
fi

clear

# Search and replace "goth-stack" with the value of PACKAGE_NAME/MODULE_PATH in all specified files, excluding node_modules, .git, and this script file
find . \( -path ./node_modules -o -path ./.git -o -path ./tools/setup.sh \) -prune -o -type f \( -name "README.md" -o -name "package.json" \) -exec sed -i '' "s|goth-stack|$PROJECT_NAME|g" {} +
if [ $? -ne 0 ]; then
    echo "\nFailed to update project name."
    exit 1
fi

find . \( -path ./node_modules -o -path ./.git -o -path ./tools/setup.sh \) -prune -o -type f \( -name "*.go" -o -name "go.mod" \) -exec sed -i '' "s|goth-stack|$MODULE_PATH|g" {} +
if [ $? -ne 0 ]; then
    echo "\nFailed to update module path."
    exit 1
fi

echo "Updated project name and module path."

sleep 1
clear

gum spin --show-error --title "Installing go dependencies..." -- go get -u all
if [ $? -ne 0 ]; then
    echo "\nFailed to install go dependencies."
    exit 1
fi

clear

gum spin --show-error --title "Installing npm dependencies..." -- npm install
if [ $? -ne 0 ]; then
    echo "\nFailed to install npm dependencies."
    exit 1
fi

clear

gum spin --show-error --title "Installing tools..." -- go install github.com/bokwoon95/wgo@latest
if [ $? -ne 0 ]; then
    echo "\nFailed to install tools."
    exit 1
fi

clear

gum spin --show-error --title "Building app..." -- make build
if [ $? -ne 0 ]; then
    echo "\nFailed to build app."
    exit 1
fi

clear

gum style \
    --foreground $PRIMARY_COLOR --border-foreground $PRIMARY_COLOR --border double \
    --align center --width 50 --margin "1 2" --padding "2 4" \
    "~~ $STYLED_GOTH $(gum style --foreground $PRIMARY_COLOR "Stack is ready! ~~")"
echo "You can now run the app with the following command:\n"
echo "\tmake start-dev"
echo "\n"
