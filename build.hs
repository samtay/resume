#!/usr/bin/env stack
{- stack runghc
  --resolver lts-11.14
  --install-ghc
  --package shake
-}

import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util

-- TODO
-- 1. loop through cover_letters and require pdf for each .tex there.
-- 2. if a user runs ./build company_name and cover_letters/company_name does
-- not exist, do the logic found in new_coverletter.sh
main :: IO ()
main = shakeArgs shakeOptions{shakeFiles="dist"} $ do
  want ["dist/resume.pdf", "dist/cv.pdf"]

  "dist/*.pdf" %> \out -> do
    command_
      [Cwd $ takeBaseName out, EchoStdout False, EchoStderr True]
      "xelatex"
      ["-output-directory","../dist",dropDirectory1 $ out -<.> "tex"]

  phony "clean" $ do
    putNormal "Cleaning files in dist"
    removeFilesAfter "dist" ["//*"]
