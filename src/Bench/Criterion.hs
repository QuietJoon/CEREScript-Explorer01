module Bench.Criterion where

import Criterion.Main
import Criterion.Main.Options
import Criterion.Types

import Interpret.Single
import Interpret.Async
-- import Interpret.Fork

import System.Environment (getArgs)


myConfig = defaultConfig {
              -- Resample 10 times for bootstrapping
              resamples = 16
            , timeLimit = 256
           }

benchAll env aScript = do
  defaultMainWith myConfig
    [ bench "Single" $ whnfIO (runS  1 aScript)
    , bench "Async"  $ whnfIO (runSA 1 aScript)
    -- , bench "Fork"   $ whnfIO (runSF 1 aScript)
    ]
  return 0
