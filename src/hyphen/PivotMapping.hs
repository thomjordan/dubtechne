{-# LANGUAGE ScopedTypeVariables #-}
module PivotMapping
  ( Scale
  , Index
  , MidiNote
  , currentScale   -- :: Scale -> ()
  , currentNote    -- :: Index -> MidiNote
  ) where

import           Data.IORef
import           System.IO.Unsafe               (unsafePerformIO)
import           Data.List                      (elemIndex, minimumBy)
import           Data.Maybe                     (fromMaybe)
import           Data.Function                  (on)

-- | Clarifying synonyms
type Scale    = [Int]
type Index    = Int
type MidiNote = Int

-- | Global IORef holding current scale
{-# NOINLINE scaleRef #-}
scaleRef :: IORef (Maybe Scale)
scaleRef = unsafePerformIO (newIORef Nothing)

-- | Global IORef holding the last (scale, index, note)
{-# NOINLINE lastRef #-}
lastRef :: IORef (Maybe (Scale, Index, MidiNote))
lastRef = unsafePerformIO (newIORef Nothing)

-- | Raw, in-IO setting of the scale
currentScaleIO :: Scale -> IO ()
currentScaleIO s = writeIORef scaleRef (Just s)

-- | Pure‐looking wrapper that actually does `currentScaleIO` under the hood
{-# NOINLINE currentScale #-}
currentScale :: Scale -> ()
currentScale s = unsafePerformIO (currentScaleIO s)

-- | Raw single‐step mapping, no state
rawMap :: Scale -> Index -> MidiNote
rawMap s i =
  let (oct, step) = i `divMod` length s
  in oct * 12 + s !! step

-- | Pivot logic on a single note
pivotOnNote :: MidiNote -> Scale -> MidiNote
pivotOnNote note s =
  let pc      = note `mod` 12
      oct     = note `div` 12
      choices = map (\d -> oct * 12 + d) s
  in case elemIndex pc s of
       Just idx -> oct * 12 + s !! idx
       Nothing  -> minimumBy (compare `on` (\x -> abs (x - note))) choices

-- | Step up/down `d` scale‐degrees from `lastNote` in a fixed scale
stepScale :: MidiNote -> Int -> Scale -> MidiNote
stepScale lastNote d s =
  let pc        = lastNote `mod` 12
      oct       = lastNote `div` 12
      len       = length s
      idx0      = fromMaybe 0 (elemIndex pc s)
      totalIdx  = idx0 + d
      (off, i2) = divMod totalIdx len
      oct'      = oct + off
  in oct' * 12 + s !! i2

-- | Raw, in-IO note lookup (with pivot + stepping)
currentNoteIO :: Index -> IO MidiNote
currentNoteIO i = do
  mbScale <- readIORef scaleRef
  case mbScale of
    Nothing     -> error "Must call currentScale first"
    Just scale' -> do

      mbLast <- readIORef lastRef
      let (n, newState) = case mbLast of

            -- No history → raw map
            Nothing ->
              let n' = rawMap scale' i
              in (n', Just (scale', i, n'))

            -- History present
            Just (oldScale, lastIdx, lastNote)
              | scale' /= oldScale ->
                -- on a new scale: pivot, then step by index‐delta
                let base = pivotOnNote lastNote scale'
                    d    = i - lastIdx
                    n'   = stepScale base d scale'
                in (n', Just (scale', i, n'))

              | otherwise ->
                -- same scale: pure stepping by index‐delta
                let d  = i - lastIdx
                    n' = stepScale lastNote d scale'
                in (n', Just (scale', i, n'))

      writeIORef lastRef newState
      return n

-- | Pure‐looking wrapper around currentNoteIO
{-# NOINLINE currentNote #-}
currentNote :: Index -> MidiNote
currentNote idx = unsafePerformIO (currentNoteIO idx)

