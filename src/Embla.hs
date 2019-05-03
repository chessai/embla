-- | This package is intended for use cases when 'cron' is overkill,
--   but the importance of avoiding drift is still there. No care is
--   taken w.r.t. GC times.
module Embla
  ( embla
  ) where

import Control.Concurrent (threadDelay)
import GHC.Clock (getMonotonicTimeNSec)
import qualified Chronos as C

-- | Given an 'IO' action and an interval at which to perform it,
--   perform the 'IO' action repeatedly at every interval. This function
--   is useful when you have an 'IO' action that can take a significant/variable
--   amount of time, and you want to avoid drift.
--
--   /Note/: This function will not work as expected if the given 'IO' action
--   takes longer than the polling interval.
--
--   /Note/: No care is taken w.r.t. GC times.
embla :: Int -> IO a -> IO a
embla interval io = do
  anchor <- fmap fromIntegral getMonotonicTimeNSec
  let go = do
        _ <- io
        threadDelay =<< solveTime anchor interval
        go
  go
 
solveTime :: ()
  => Int
  -> Int
  -> IO Int
solveTime t0 p = do
  C.Time now' <- C.now
  let now = fromIntegral now'
  let p' = p * 1000000000
  let untilNextTime = ((div (now - t0) p') + 1) * p'
  let solved = div (t0 + untilNextTime - now) 1000
  pure solved 
