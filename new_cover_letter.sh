#!/usr/bin/env bash
set -eo pipefail

main() {
  company_name="$1"
  company_label="$2"
  company_dir="cover_letters/$company_name"
  declare -a resources=("awesome-cv.cls" "fontawesome.sty" "fonts")

  mkdir "$company_dir"

  for resource in "${resources[@]}"; do
    ln -s ../../awesome/"$resource" "$company_dir"
  done

  cp awesome/coverletter.tex "$company_dir"

  cd "$company_dir"
  if [[ ! -z "$company_label" ]]; then
    sed -i "s/COMPANY/$company_label/g" coverletter.tex
  fi
  xelatex coverletter.tex
}

main "$@"
