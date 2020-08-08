# Check is variable has a value or it is empty.
function IsValExist {
  local name="$1"
  local value="$2"
  echo "$1 and $2"
  [ -z "$value" ] && { echo "[ $value ]"; ErrorMessage "Variable [ $name ] is empty. Exit"; exit 1; }
}

# Check if file exist
function IsFileExist {
  local filepath="$1"
  [ -f "$filepath" ] || { ErrorMessage " File does not exist."; exit 1; }
}
