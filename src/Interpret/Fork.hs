{-# LANGUAGE RecordWildCards #-}

module Interpret.Fork where

import Control.Concurrent (ThreadId, forkIO)
import Control.Concurrent.STM (TVar, atomically, newTVarIO, readTVar, retry, writeTVar)

import Script

runSF :: Env -> Script F -> Context Env
runSF env E = return env
runSF env A{..} = do
  preEnv <- runSF env aNext
  inst preEnv
-- TODO: Not finished yet
{-
runSF env B{..} = do
  preEnv <- runSF env bNext
  tv <- newTVarIO 0
  mapM_ (fork' tv preEnv) branchScripts
  -- ! Needs finish check
  readTVar tv
  where
    fork' tv env aScript = forkIO $ do
      preEnv <- runSF env aNext
      atomically (readTVar tv >>= writeTVar tv . (+preEnv))
-}
