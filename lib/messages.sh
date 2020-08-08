function JobInitMessage {
  local text="$1"
cat <<EOF
 * $text
EOF
}

function SubJobMessage {
  local text="$1"
cat <<EOF
    * $text
EOF
}

function ChangeValueMessage {
  local text="$1"
cat <<EOF
      | Changing $text
EOF
}

function DebugMessage {
  if [ $DEBUG_MODE = 1 ]; then
    local text="$1"
    cat <<EOF
  DEBUG | $text
EOF
  fi
}

function ErrorMessage {
  local text="$1"
cat <<EOF
 Error | $text
 Exit.
EOF
exit 1
}
