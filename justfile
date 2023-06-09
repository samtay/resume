default: artifacts

resume := "resume"
cv := "cv"

# build resume/cv
build target=resume:
  #!/bin/sh
  mkdir -p dist
  cd {{target}}
  xelatex -output-directory ../dist -jobname {{target}} main.tex

# watch resume/cv
watch target=resume: (build target)
  #!/bin/sh
  zathura dist/{{target}}.pdf &
  watchexec --exts tex -- just build {{target}}

# build a cover letter
build-cover-letter target:
  #!/bin/sh
  mkdir -p dist/cover-letters
  cd cover-letters/{{target}}
  xelatex -output-directory ../../dist/cover-letters -jobname {{target}} main.tex

# watch a cover letter
watch-cover-letter target: (build-cover-letter target)
  #!/bin/sh
  zathura dist/cover-letters/{{target}}.pdf &
  watchexec --exts tex -- just build-cover-letter {{target}}

# copy to artifacts
artifacts: (build resume) (build cv)
  cp dist/resume.pdf dist/cv.pdf artifacts/
