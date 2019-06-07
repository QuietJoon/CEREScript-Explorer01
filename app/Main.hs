{-# LANGUAGE RecordWildCards #-}

module Main where

-- import Control.Parallel
-- import Control.Parallel.Strategies
import Control.Concurrent.Async

import Criterion.Main
import Criterion.Main.Options
import Criterion.Types

import System.Environment (getArgs)

import Debug.Trace

myConfig = defaultConfig {
              -- Resample 10 times for bootstrapping
              resamples = 16
            , timeLimit = 256
           }


data Script a
  = B
  { branchCondition :: Env -> Int
  , branchScripts :: [Script a]
  , bNext :: (Script a)
  }
  | A { inst :: a, aNext :: Script a}
  | E -- End of Script, No more next instruction

instance Show (Script a) where
  show B{..} = "B [" ++ (concatMap show branchScripts) ++ "]"
  --show A{..} = "A <" ++ show aNext ++ ">"
  show A{..} = show aNext
  show E = "|E|"

rNum :: Int
rNum = 1048576

type F = Env -> Context Env
type Context = IO
type Env = Int

repeatA :: Int -> Script F
repeatA mulO = makeRepeatA (mulEnv mulO) rNum

makeRepeatA :: F -> Int -> Script F
makeRepeatA _ 0 = E
makeRepeatA f num = A f $ makeRepeatA f (num-1)

mulEnv :: Env -> Env -> Context Env
mulEnv m e = return $ m * e

runS :: Env -> Script F -> Context Env
runS env E = return env
runS env A{..} = do
  preEnv <- runS env aNext
  inst preEnv
runS env B{..} = do
  preEnv <- runS env bNext
  results <- mapM (runS preEnv) branchScripts
  return $ sum results

runSC :: Env -> Script F -> Context Env
runSC env E = return env
runSC env A{..} = do
  preEnv <- runSC env aNext
  inst preEnv
runSC env B{..} = do
  preEnv <- runSC env bNext
  results <- mapConcurrently (runSC preEnv) branchScripts
  return $ sum results

branchedScript :: Script F
branchedScript = B (\_ -> 1) (map repeatA [2,3,5,7,11,13,17,23]) E
aScript :: Script F
aScript = A (mulEnv 11) $ branchedScript { bNext = (A (mulEnv 13) E)}

main :: IO ()
main = do
  putStrLn "Run TestParBranch"
  print aScript
  {-
  defaultMainWith myConfig
    [ bench "S" $ whnfIO (runS  1 aScript)
    , bench "C" $ whnfIO (runSC 1 aScript)
    ]
  -}
  args <- getArgs
  result <- case args of
    ("single":_) -> runS  1 aScript
    ("conc":_)   -> runSC 1 aScript
    _ -> return 0
  print result
