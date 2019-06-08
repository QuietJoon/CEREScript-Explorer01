{-# LANGUAGE RecordWildCards #-}

module Script where

type F = Env -> Context Env
type Context = IO
type Env = Int

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

repeatA :: Int -> Int -> Script F
repeatA num mulO = makeRepeatA (mulEnv mulO) num

makeRepeatA :: F -> Int -> Script F
makeRepeatA _ 0 = E
makeRepeatA f num = A f $ makeRepeatA f (num-1)

mulEnv :: Env -> Env -> Context Env
mulEnv m e = return $ m * e
