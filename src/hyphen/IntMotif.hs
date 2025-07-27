module IntMotif where

import Numeric (showHex)
import Data.Char (digitToInt, isHexDigit, toUpper)

toHex :: (Integral a, Show a) => a -> Char
toHex x = (map toUpper $ showHex (x `mod` 16) "") !! 0

fromHex :: Char -> Int
fromHex c
  | isHexDigit c = digitToInt (toUpper c)
  | otherwise    = 0

groupNBits :: Int -> [Int] -> [[Int]]
groupNBits _ [] = []
groupNBits n bits
  | length bits < n = []  -- Ignore incomplete final group
  | otherwise = take n bits : groupNBits n (drop n bits)

bitsToInt :: [Int] -> Int
bitsToInt = foldl (\acc bit -> acc * 2 + bit) 0

extractNBits :: Int -> [Int] -> [Int]
extractNBits n bits = map bitsToInt (groupNBits n bits)

lake :: [Int]
lake = [0,1,1,0,1,1,0,1,1,0,1,0,0,1,1,0,0,0,0,1,1,1,0,0,0,1,0,1,0,0,0,0,0,1,0,0,0,0,1,1,0,0,0,0,1,0,1,1]

--extractNBits 2 lake
-- ➝ [1,2,3,1,2,2,1,0,3,0,0,1,2,0,0,0,3,3,0,0,1,1,0,0]

--extractNBits 3 lake
-- ➝ [3,5,6,5,2,1,6,0,1,7,0,1,2,0,0,2]

--extractNBits 4 lake
-- ➝ [6,11,6,10,3,6,0,7,0,10,0,0]

wen :: [Int]
wen = [ 7,7,  0,0,  4,2,  2,1,  7,2,  2,7,  2,0,  0,2 
      , 7,3,  6,7,  7,0,  0,7,  5,7,  7,5,  1,0,  0,4 
      , 4,6,  3,1,  6,0,  0,3,  4,5,  5,1,  0,1,  4,0
      , 4,7,  7,1,  4,1,  3,6,  2,2,  5,5,  1,6,  3,4
      , 1,7,  7,4,  0,5,  5,0,  5,3,  6,5,  1,2,  2,4
      , 6,1,  4,3,  7,6,  3,7,  0,6,  3,0,  2,6,  3,2
      , 5,6,  3,5,  4,4,  1,1,  1,3,  6,4,  5,4,  1,5
      , 3,3,  6,6,  2,3,  6,2,  6,3,  1,4,  5,2,  2,5 ]

wenToTri :: Int -> [Int]
wenToTri n = [wen !! index, wen !! (index+1)] 
    where index = ((n-1) `mod` 64) * 2  

wenToInt :: Int -> Int
wenToInt n = (pair !! 0) * 8 + (pair !! 1) where pair = wenToTri n

intToWen :: Int -> Int
intToWen n = inverseWenList !! n
    where inverseWenList = [2,23,8,20,16,33,44,12,15,53,37,60,62,56,31,32,7,4,29,58,38,64,47,6,18,17,48,57,30,50,28,43
                           ,24,27,3,41,51,21,5,25,34,22,61,36,55,59,49,13,19,39,26,36,54,40,11,10,9,26,1,58,35,14,63,1]

wenListToInt :: [Int] -> [Int]
wenListToInt ws = map wenToInt ws

intListToWen :: [Int] -> [Int]
intListToWen ns = map intToWen ns

intToBits :: Int -> Int -> [Int]
intToBits n val = reverse (take n (reverse (toBits val) ++ repeat 0))
  where
    toBits 0 = []
    toBits x = toBits (x `div` 2) ++ [x `mod` 2]

wenListToBin :: [Int] -> [Int]
wenListToBin ws = concat $ map (intToBits 3) $ concat $ map wenToTri ws

wenListToTri :: [Int] -> [Int]
wenListToTri ws = concat $ map wenToTri ws

triListToBin :: [Int] -> [Int]
triListToBin trigrams = concat $ map (intToBits 3) trigrams

triToHouse :: Int -> [Int]
triToHouse trigram = houseList !! (trigram `mod` 8)
    where houseList = [[ 2,24,19,11,34,43, 5, 8]
                      ,[52,22,26,41,38,10,61,53]
                      ,[29,60, 3,63,49,55,36, 7]
                      ,[57, 9,37,42,25,21,27,18]
                      ,[51,16,40,32,46,48,28,17]
                      ,[30,56,50,64, 4,59, 6,13] 
                      ,[58,47,45,31,39,15,62,54]
                      ,[ 1,44,33,12,20,23,35,14]]

triToHouseTri :: Int -> [Int]
triToHouseTri trigram = wenListToTri $ triToHouse trigram

triToHouseBin :: Int -> [Int]
triToHouseBin trigram = wenListToBin $ triToHouse trigram

triToHouseHex :: Int -> [Char]
triToHouseHex trigram = map toHex $ extractNBits 4 $ triToHouseBin trigram

wenListToHex :: [Int] -> [Char]
wenListToHex ws = map toHex $ extractNBits 4 $ wenListToBin ws

hexStrToBinLists :: [Char] -> [[Int]]
hexStrToBinLists hexstr = map (\x -> intToBits 4 $ fromHex x) hexstr 

hexStrToBin :: [Char] -> [Int]
hexStrToBin hexstr = concat $ hexStrToBinLists hexstr

binListToWen :: [Int] -> [Int]
binListToWen binList = map intToWen $ extractNBits 6 binList

binListToHex :: [Int] -> [Char]
binListToHex binList = map toHex $ extractNBits 4 binList

binListToTri :: [Int] -> [Int]
binListToTri binList = extractNBits 3 binList

binListToBi :: [Int] -> [Int]
binListToBi binList = extractNBits 2 binList

mapSelect :: [[a]] -> [Int] -> [a]
mapSelect materials indices =
  concatMap select indices
  where
    len = length materials
    select i = materials !! (i `mod` len)

elemRepeat :: Int -> [a] -> [a]
elemRepeat n = concatMap (replicate n)

wenToHouseBinMix :: Int -> [Int]
wenToHouseBinMix wen = concatMap (\(x, y) -> [x, y]) (zip earthHouse $ reverse skyHouse)
  where earthHouse = triToHouseBin $ (wenToTri wen) !! 0
        skyHouse   = triToHouseBin $ (wenToTri wen) !! 1

wenToHouseTriMix :: Int -> [Int]
wenToHouseTriMix wen = concatMap (\(x, y) -> [x, y]) (zip earthHouse $ reverse skyHouse)
  where earthHouse = triToHouseTri $ (wenToTri wen) !! 0
        skyHouse   = triToHouseTri $ (wenToTri wen) !! 1









