module Main where

-- import Control.Parallel
-- import Control.Parallel.Strategies
import Control.Concurrent.Async

import Bench.Criterion
import Interpret.Single
import Interpret.Async
-- import Interpret.Fork
import Script

import System.Environment (getArgs)

rNum :: Int
rNum = 1048576

branchedScript :: Script F
branchedScript = B (\_ -> 1) (map (repeatA rNum) [2,3,5,7,11,13,17,23]) E
aScript :: Script F
aScript = A (mulEnv 11) $ branchedScript { bNext = (A (mulEnv 13) E)}

main :: IO ()
main = do
  print aScript
  args <- getArgs
  result <- case args of
    ("evalScript":_) -> return 0
    ("single":_) -> runS  1 aScript
    ("async":_)  -> runSA 1 aScript
    -- ("fork":_)   -> runSF 1 aScript
    _ -> do
      print "\n\nBench\n\n"
      benchAll 1 aScript
  print result
