#!/usr/bin/env stack
{- stack runghc
  --resolver lts-15.8
  --install-ghc
  --package shake
-}

import Development.Shake
import Development.Shake.Command
import Development.Shake.FilePath
import Development.Shake.Util

-- TODO
-- 1. if a user runs ./build company_name and cover_letters/company_name does
-- not exist, do the logic found in new_coverletter.sh
main :: IO ()
main = shakeArgs shakeOptions{shakeFiles="dist", shakeProgress=progressSimple} $ do
  let targets = [ "resume.pdf"
                , "cv.pdf"
                ]
  statements <- liftIO $ fmap takeDirectory1 <$> getDirectoryFilesIO "statements" ["*/main.tex"]

  want $ ["dist" </> target | target <- targets]
      ++ ["dist/statements" </> statement -<.> "pdf" | statement <- statements]

  "dist/*.pdf" %> \out -> do
    let n = takeBaseName out
    need =<< getDirectoryFiles "" [n <//> "*"]
    command_
      [Cwd n, EchoStdout True, EchoStderr True]
      "xelatex"
      ["-output-directory", "../dist", "-jobname", n, "main.tex"]

  "dist/statements/*.pdf" %> \out -> do
    let n = takeBaseName out
    need =<< getDirectoryFiles "" ["statements/*", "statements" </> n </> "main.tex"]
    command_
      [Cwd "statements", EchoStdout True, EchoStderr True]
      "xelatex"
      ["-output-directory", "../dist/statements/", "-jobname", n, n </> "main.tex"]

  phony "clean" $ do
    putNormal "Cleaning files in dist"
    removeFilesAfter "dist" ["//*"]

  phony "artifacts" $ do
    need ["dist" </> target | target <- targets]
    putNormal "Copying targets from dist to artifacts"
    mapM_ (uncurry copyFileChanged) $
      [("dist" </> t, "artifacts" </> t) | t <- targets]
