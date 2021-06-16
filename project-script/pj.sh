#!/usr/bin/env bash

DIRECTORIES_LIST=(
repos
doc
security
)

function createDirStructure {
  mkdir -p @

}

function checkDependencies {

}

function createNewProject {
  checkDependencies @1
}

function createTmuxDirAliases {
  local ui="get ui repo"
  local backend="get backend repo"
  local ui="get ui repo"

  mv $current_ui_repo ui
  mv $current_backend_repo backend
}
