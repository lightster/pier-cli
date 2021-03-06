function moor()
{
  export PIER_MOOR_BASH=1

  if [[ "cd" == "$1" ]]; then
    local cd_dir
    local exit_code
    # declare vars before setting them, otherwise the exit code is from `local`
    cd_dir=$(command moor cd-dir "${@:2}" </dev/null)
    exit_code=$?

    if [ ${exit_code} -eq 1 ]; then
      echo "${cd_dir}"
      return 1
    elif [ ${exit_code} -ne 0 ]; then
      echo "Directory to change to could not be determined. Command returned:" >&2
      echo "${cd_dir}" >&2
      return ${exit_code}
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
