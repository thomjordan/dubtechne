module IntMotif where

import Numeric (showHex)
import Data.Char (digitToInt, isHexDigit, toUpper)

intToHex :: (Integral a, Show a) => a -> Char
intToHex x = (map toUpper $ showHex (x `mod` 16) "") !! 0

hexToInt :: Char -> Int
hexToInt c
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
    where inverseWenList = [2,23,8,20,16,35,45,12,15,52,39,53,62,56,31,33,7,4,29,59,40,64,47,6,46,18,48,57,32,50,28,44
                           ,24,27,3,42,51,21,17,25,36,22,63,37,55,30,49,13,19,41,60,61,54,38,58,10,11,26,5,9,34,14,43,1]

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
triToHouseHex trigram = map intToHex $ extractNBits 4 $ triToHouseBin trigram

wenListToHex :: [Int] -> [Char]
wenListToHex ws = map intToHex $ extractNBits 4 $ wenListToBin ws

hexToBin :: Char -> [Int]
hexToBin c = intToBits 4 $ hexToInt c

hexStrToBinLists :: [Char] -> [[Int]]
hexStrToBinLists hexstr = map hexToBin hexstr 

hexStrToBin :: [Char] -> [Int]
hexStrToBin hexstr = concat $ hexStrToBinLists hexstr

toWen :: [Int] -> [Int]
toWen binList = map intToWen $ extractNBits 6 binList

toGua :: [Int] -> [Int]
toGua binList = extractNBits 6 binList

toHex :: [Int] -> [Char]
toHex binList = map intToHex $ extractNBits 4 binList

toTri :: [Int] -> [Int]
toTri binList = extractNBits 3 binList

toBi :: [Int] -> [Int]
toBi binList = extractNBits 2 binList

toBin :: Int -> [Int] -> [Int]
toBin n xs = concat $ map (intToBits n) xs

mapSelect :: [[a]] -> [Int] -> [a]
mapSelect materials indices =
  concatMap select indices
  where
    len = length materials
    select i = materials !! (i `mod` len)

elemRepeat :: Int -> [a] -> [a]
elemRepeat n = concatMap (replicate n)

wenToHouseMix :: ([Int] -> [a]) -> Int -> [a]
wenToHouseMix binReader wen = concatMap (\(x, y) -> [x, y]) (zip earthHouse $ reverse skyHouse)
  where skyHouse   = binReader $ triToHouseBin $ (wenToTri wen) !! 1
        earthHouse = binReader $ triToHouseBin $ (wenToTri wen) !! 0

wenToHouseMixGua :: Int -> [Int]
wenToHouseMixGua wen = toBin 6 $ wenToHouseMix toGua wen

wenToHouseMixHex :: Int -> [Int]
wenToHouseMixHex wen =  hexStrToBin $ wenToHouseMix toHex wen

wenToHouseMixTri :: Int -> [Int]
wenToHouseMixTri wen = toBin 3 $ wenToHouseMix toTri wen

wenToHouseMixBi :: Int -> [Int]
wenToHouseMixBi wen = toBin 2 $ wenToHouseMix toBi wen

wenToHouseMixBin :: Int -> [Int]
wenToHouseMixBin wen = wenToHouseMix id wen

wenToHouseMixGua2 = toBi . wenToHouseMixGua
wenToHouseMixGua3 = toTri . wenToHouseMixGua
wenToHouseMixGua4 = toHex . wenToHouseMixGua
wenToHouseMixGua6 = toGua . wenToHouseMixGua
 
wenToHouseMixHex2 = toBi . wenToHouseMixHex
wenToHouseMixHex3 = toTri . wenToHouseMixHex
wenToHouseMixHex4 = toHex . wenToHouseMixHex
wenToHouseMixHex6 = toGua . wenToHouseMixHex
 
wenToHouseMixTri2 = toBi . wenToHouseMixTri
wenToHouseMixTri3 = toTri . wenToHouseMixTri
wenToHouseMixTri4 = toHex . wenToHouseMixTri
wenToHouseMixTri6 = toGua . wenToHouseMixTri
 
wenToHouseMixBi2 = toBi . wenToHouseMixBi
wenToHouseMixBi3 = toTri . wenToHouseMixBi
wenToHouseMixBi4 = toHex . wenToHouseMixBi
wenToHouseMixBi6 = toGua . wenToHouseMixBi
 
wenToHouseMixBin2 = toBi . wenToHouseMixBin
wenToHouseMixBin3 = toTri . wenToHouseMixBin
wenToHouseMixBin4 = toHex . wenToHouseMixBin
wenToHouseMixBin6 = toGua . wenToHouseMixBin
