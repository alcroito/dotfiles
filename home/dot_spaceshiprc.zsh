SPACESHIP_PROMPT_ASYNC=true
SPACESHIP_PROMPT_ADD_NEWLINE=true
SPACESHIP_CHAR_SYMBOL="$ "

SPACESHIP_DIR_PREFIX=""

# Display username always
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_PREFIX="" # remove `with` before username
SPACESHIP_USER_SUFFIX="" # remove space before host

SPACESHIP_HOST_COLOR="green"
SPACESHIP_DIR_COLOR="blue"

# This sets host to be always displayed
SPACESHIP_HOST_SHOW="always"

SPACESHIP_HOST_PREFIX="@"

# Do not truncate path in repos
SPACESHIP_DIR_TRUNC="0"
SPACESHIP_DIR_TRUNC_REPO="false"

SPACESHIP_GIT_BRANCH_COLOR="yellow"

# Only load what you actually use
SPACESHIP_PROMPT_ORDER=(
    user
    host
    dir
    git
    exec_time
    exit_code
    line_sep
    char
)
