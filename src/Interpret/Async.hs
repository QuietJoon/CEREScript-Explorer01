{-# LANGUAGE RecordWildCards #-}

module Interpret.Async where

import Control.Concurrent.Async

import Script


runSA :: Env -> Script F -> IO Env
runSA env E = return env
runSA env A{..} = do
  preEnv <- runSA env aNext
  inst preEnv
runSA env B{..} = do
  preEnv <- runSA env bNext
  results <- mapConcurrently (runSA preEnv) branchScripts
  return $ sum results
