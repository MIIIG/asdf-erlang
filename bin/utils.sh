KERL_VERSION="2.1.2"

handle_failure() {
  function=$1
  error_message=$2
  $function && exit_code=$? || exit_code=$?

  if [ "$exit_code" -ne 0 ]; then
    printf "$error_message"
  fi

  return "$exit_code"
}

ensure_kerl_setup() {
  handle_failure set_kerl_env 'Failed to set kerl environment\n'
  handle_failure ensure_kerl_installed 'Failed to install kerl\n'
  handle_failure update_available_versions 'Failed to update available versions\n'
}

ensure_kerl_installed() {
    if [ ! -f "$(kerl_path)" ]; then
        download_kerl
    elif [ "$("$(kerl_path)" version)" != "$KERL_VERSION" ]; then
        # If the kerl file already exists and the version does not match, remove
        # it and download the correct version
        rm "$(kerl_path)"
        download_kerl
    fi
}

download_kerl() {
    # Print to stderr so asdf doesn't assume this string is a list of versions
    echo "Downloading kerl..." >&2

    local kerl_url="https://raw.githubusercontent.com/kerl/kerl/${KERL_VERSION}/kerl"

    curl -Lso "$(kerl_path)" $kerl_url
    chmod +x "$(kerl_path)"
}

kerl_path() {
    echo "$(dirname "$(dirname $0)")/kerl"
}

set_kerl_env() {
    local kerl_home
    kerl_home="$(dirname "$(dirname "$0")")/kerl-home"
    mkdir -p "$kerl_home"
    export KERL_BASE_DIR="$kerl_home"
    export KERL_BUILD_BACKEND="git"
    export KERL_CONFIG="$kerl_home/.kerlrc"
}

update_available_versions() {
    "$(kerl_path)" update releases > /dev/null
}
