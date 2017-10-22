function moor()
{
  if [[ "cd" == "$1" ]]; then
    local cd_dir
    local exit_code
    # declare vars before setting them, otherwise the exit code is from `local`
    cd_dir=$(command moor cd-dir "${@:2}")
    exit_code=$?

    if [ ${exit_code} -ne 0 ]; then
      echo "Directory to change to could not be determined. Command returned:" >&2
      echo "${cd_dir}" >&2
      return 1
    fi

    cd "${cd_dir}"
    exit_code=$?

    if [ ${exit_code} -ne 0 ]; then
      echo "Could not change directory. Attempted:" >&2
      echo "cd ${cd_dir}" >&2
      return 1
    fi
  else
    command moor "$@"
  fi
}
