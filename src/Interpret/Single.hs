{-# LANGUAGE RecordWildCards #-}

module Interpret.Single where

import Script


runS :: Env -> Script F -> IO Env
runS env E = return env
runS env A{..} = do
  preEnv <- runS env aNext
  seq preEnv (inst preEnv)
runS env B{..} = do
  preEnv <- runS env bNext
  results <- mapM (runS preEnv) branchScripts
  return $ sum results
