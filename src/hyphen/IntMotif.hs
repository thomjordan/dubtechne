{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeApplications #-}

module IntMotif where

import Numeric (showHex)
import Data.Coerce (coerce, Coercible(..))
import Data.Char (digitToInt, isHexDigit, toUpper)

newtype Wen = Wen [Int]  deriving (Eq, Ord, Show)
newtype Hex = Hex [Int]  deriving (Eq, Ord, Show)
newtype Hxd = Hxd [Char] deriving (Eq, Ord, Show)
newtype Qua = Qua [Int]  deriving (Eq, Ord, Show)
newtype Tri = Tri [Int]  deriving (Eq, Ord, Show)
newtype Big = Big [Int]  deriving (Eq, Ord, Show)
newtype Bin = Bin [Int]  deriving (Eq, Ord, Show)


-- Typeclass for conversion to Wen
class ToWen a where
  toWen :: a -> Wen

-- Typeclass for conversion to Hex
class ToHex a where
  toHex :: a -> Hex

-- Typeclass for conversion to Hxd
class ToHxd a where
  toHxd :: a -> Hxd

-- Typeclass for conversion to Qua
class ToQua a where
  toQua :: a -> Qua

-- Typeclass for conversion to Tri
class ToTri a where
  toTri :: a -> Tri

-- Typeclass for conversion to Big
class ToBig a where
  toBig :: a -> Big

-- Typeclass for conversion to Bin
class ToBin a where
  toBin :: a -> Bin

-- Instance for converting from Hex to Wen
instance ToWen Hex where
  toWen = coerce hex_to_wen

-- Instance for converting from Qua to Wen
instance ToWen Qua where
  toWen = coerce $ bin_to_wen . qua_to_bin

-- Instance for converting from Tri to Wen
instance ToWen Tri where
  toWen = coerce $ bin_to_wen . tri_to_bin

-- Instance for converting from Big to Wen
instance ToWen Big where
  toWen = coerce $ bin_to_wen . big_to_bin

-- Instance for converting from Bin to Wen
instance ToWen Bin where
  toWen = coerce bin_to_wen

-- Instance for converting from Wen to Hex
instance ToHex Wen where
  toHex = coerce wen_to_hex

-- Instance for converting from Qua to Hex
instance ToHex Qua where
  toHex = coerce $ bin_to_hex . qua_to_bin

-- Instance for converting from Tri to Hex
instance ToHex Tri where
  toHex = coerce $ bin_to_hex . tri_to_bin

-- Instance for converting from Big to Hex
instance ToHex Big where
  toHex = coerce $ bin_to_hex . big_to_bin

-- Instance for converting from Bin to Hex
instance ToHex Bin where
  toHex = coerce bin_to_hex

-- Instance for converting from Wen to Hxd
instance ToHxd Wen where
  toHxd = coerce $ bin_to_hxd . wen_to_bin

-- Instance for converting from Hex to Hxd
instance ToHxd Hex where
  toHxd = coerce $ bin_to_hxd . hex_to_bin

-- Instance for converting from Qua to Hxd
instance ToHxd Qua where
  toHxd = coerce $ bin_to_hxd . qua_to_bin

-- Instance for converting from Tri to Hxd
instance ToHxd Tri where
  toHxd = coerce $ bin_to_hxd . tri_to_bin

-- Instance for converting from Big to Hxd
instance ToHxd Big where
  toHxd = coerce $ bin_to_hxd . big_to_bin

-- Instance for converting from Bin to Hxd
instance ToHxd Bin where
  toHxd = coerce bin_to_hxd

-- Instance for converting from Wen to Qua
instance ToQua Wen where
  toQua = coerce $ bin_to_qua . wen_to_bin

-- Instance for converting from Hex to Qua
instance ToQua Hex where
  toQua = coerce $ bin_to_qua . hex_to_bin

-- Instance for converting from Tri to Qua
instance ToQua Tri where
  toQua = coerce $ bin_to_qua . tri_to_bin

-- Instance for converting from Big to Qua
instance ToQua Big where
  toQua = coerce $ bin_to_qua . big_to_bin

-- Instance for converting from Bin to Qua
instance ToQua Bin where
  toQua = coerce bin_to_qua

-- Instance for converting from Wen to Tri
instance ToTri Wen where
  toTri = coerce $ bin_to_tri . wen_to_bin

-- Instance for converting from Hex to Tri
instance ToTri Hex where
  toTri = coerce $ bin_to_tri . hex_to_bin

-- Instance for converting from Qua to Tri
instance ToTri Qua where
  toTri = coerce $ bin_to_tri . qua_to_bin

-- Instance for converting from Big to Tri
instance ToTri Big where
  toTri = coerce $ bin_to_tri . big_to_bin

-- Instance for converting from Bin to Tri
instance ToTri Bin where
  toTri = coerce bin_to_tri

-- Instance for converting from Wen to Big
instance ToBig Wen where
  toBig = coerce $ bin_to_big . wen_to_bin

-- Instance for converting from Hex to Big
instance ToBig Hex where
  toBig = coerce $ bin_to_big . hex_to_bin

-- Instance for converting from Qua to Big
instance ToBig Qua where
  toBig = coerce $ bin_to_big . qua_to_bin

-- Instance for converting from Tri to Big
instance ToBig Tri where
  toBig = coerce $ bin_to_big . tri_to_bin

-- Instance for converting from Bin to Big
instance ToBig Bin where
  toBig = coerce bin_to_big

-- Instance for converting from Wen to Bin
instance ToBin Wen where
  toBin = coerce wen_to_bin

-- Instance for converting from Hex to Bin
instance ToBin Hex where
  toBin = coerce hex_to_bin

-- Instance for converting from Hxd to Bin
instance ToBin Hxd where
  toBin = coerce hxd_to_bin

-- Instance for converting from Qua to Bin
instance ToBin Qua where
  toBin = coerce qua_to_bin

-- Instance for converting from Tri to Bin
instance ToBin Tri where
  toBin = coerce tri_to_bin

-- Instance for converting from Big to Bin
instance ToBin Big where
  toBin = coerce big_to_bin

intToHxd :: (Integral a, Show a) => a -> Char
intToHxd x = (map toUpper $ showHex (x `mod` 16) "") !! 0

hxdToInt :: Char -> Int
hxdToInt c
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

kingWen :: [Int]
kingWen = [ 7,7,  0,0,  4,2,  2,1,  7,2,  2,7,  2,0,  0,2 
          , 7,3,  6,7,  7,0,  0,7,  5,7,  7,5,  1,0,  0,4 
          , 4,6,  3,1,  6,0,  0,3,  4,5,  5,1,  0,1,  4,0
          , 4,7,  7,1,  4,1,  3,6,  2,2,  5,5,  1,6,  3,4
          , 1,7,  7,4,  0,5,  5,0,  5,3,  6,5,  1,2,  2,4
          , 6,1,  4,3,  7,6,  3,7,  0,6,  3,0,  2,6,  3,2
          , 5,6,  3,5,  4,4,  1,1,  1,3,  6,4,  5,4,  1,5
          , 3,3,  6,6,  2,3,  6,2,  6,3,  1,4,  5,2,  2,5 ]

wenToTri :: Int -> [Int]
wenToTri n = [kingWen !! index, kingWen !! (index+1)] 
    where index = ((n-1) `mod` 64) * 2  

wen_to_hex :: [Int] -> [Int]
wen_to_hex ws = map wenToHex ws
    where wenToHex n = (pair !! 0) * 8 + (pair !! 1) where pair = wenToTri n

hex_to_wen :: [Int] -> [Int]
hex_to_wen ns = map (\n -> inverseWenList !! n) ns
    where inverseWenList = [2,23,8,20,16,35,45,12,15,52,39,53,62,56,31,33,7,4,29,59,40,64,47,6,46,18,48,57,32,50,28,44
                           ,24,27,3,42,51,21,17,25,36,22,63,37,55,30,49,13,19,41,60,61,54,38,58,10,11,26,5,9,34,14,43,1]

hex_to_bin :: [Int] -> [Int]
hex_to_bin = concatMap (intToBits 6)

intToBits :: Int -> Int -> [Int]
intToBits n val = reverse (take n (reverse (toBits modval) ++ repeat 0))
  where
    modval = val `mod` (2^n)
    toBits 0 = []
    toBits x = toBits (x `div` 2) ++ [x `mod` 2]

wen_to_tri :: [Int] -> [Int]
wen_to_tri ws = concat $ map wenToTri ws

wen_to_bin :: [Int] -> [Int]
wen_to_bin ws = concatMap (intToBits 6) (wen_to_hex ws)

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
triToHouseTri trigram = wen_to_tri $ triToHouse trigram

triToHouseBin :: Int -> [Int]
triToHouseBin trigram = wen_to_bin $ triToHouse trigram

triToHouseHxd :: Int -> [Char]
triToHouseHxd trigram = map intToHxd $ extractNBits 4 $ triToHouseBin trigram

wen_to_hxd :: [Int] -> [Char]
wen_to_hxd ws = map intToHxd $ extractNBits 4 $ wen_to_bin ws

hxd_to_binlists :: [Char] -> [[Int]]
hxd_to_binlists hxstr = map (\c -> intToBits 4 $ hxdToInt c) hxstr 

hxd_to_bin :: [Char] -> [Int]
hxd_to_bin hxstr = concat $ hxd_to_binlists hxstr

qua_to_bin :: [Int] -> [Int]
qua_to_bin = concatMap (intToBits 4)

tri_to_bin :: [Int] -> [Int]
tri_to_bin = concatMap (intToBits 3)

big_to_bin :: [Int] -> [Int]
big_to_bin = concatMap (intToBits 2)

bin_to_wen :: [Int] -> [Int]
bin_to_wen binList = hex_to_wen $ extractNBits 6 binList

bin_to_hex :: [Int] -> [Int]
bin_to_hex binList = extractNBits 6 binList

bin_to_hxd :: [Int] -> [Char]
bin_to_hxd binList = map intToHxd $ extractNBits 4 binList

bin_to_qua :: [Int] -> [Int]
bin_to_qua binList = extractNBits 4 binList

bin_to_tri :: [Int] -> [Int]
bin_to_tri binList = extractNBits 3 binList

bin_to_big :: [Int] -> [Int]
bin_to_big binList = extractNBits 2 binList

intListToBin :: Int -> [Int] -> [Int]
intListToBin n xs = concat $ map (intToBits n) xs

mapSelect :: [[a]] -> [Int] -> [a]
mapSelect materials indices =
  concatMap select indices
  where
    len = length materials
    select i = materials !! (i `mod` len)

elemRepeat :: Int -> [a] -> [a]
elemRepeat n = concatMap (replicate n)

class WenToHouseMix a where
  wenToHouseMix' :: ([Int] -> a) -> Int -> Bin

instance WenToHouseMix Wen where
  wenToHouseMix' br w = Bin $ wen_to_bin $ wen_to_house_mix (coerce . br) w

instance WenToHouseMix Hex where
  wenToHouseMix' br w = Bin $ intListToBin 6 $ wen_to_house_mix (coerce . br) w

instance WenToHouseMix Qua where
  wenToHouseMix' br w = Bin $ intListToBin 4 $ wen_to_house_mix (coerce . br) w

instance WenToHouseMix Tri where
  wenToHouseMix' br w = Bin $ intListToBin 3 $ wen_to_house_mix (coerce . br) w

instance WenToHouseMix Big where
  wenToHouseMix' br w = Bin $ intListToBin 2 $ wen_to_house_mix (coerce . br) w

instance WenToHouseMix Bin where
  wenToHouseMix' br w = Bin $ wen_to_house_mix (coerce . br) w

-- Helper function to automatically wrap in Bin
wenToHouseMix :: WenToHouseMix a => (Bin -> a) -> Int -> Bin
wenToHouseMix br w = wenToHouseMix' (br . Bin) w

wen_to_house_mix :: ([Int] -> [a]) -> Int -> [a]
wen_to_house_mix binReader wen = concatMap (\(x, y) -> [x, y]) (zip earthHouse $ reverse skyHouse)
  where skyHouse   = binReader $ triToHouseBin  $ (wenToTri wen) !! 1
        earthHouse = binReader $ triToHouseBin  $ (wenToTri wen) !! 0

oddIndexedElements :: [a] -> [a]
oddIndexedElements xs = [val | (idx, val) <- zip [0..] xs, odd idx]

evenIndexedElements :: [a] -> [a]
evenIndexedElements xs = [val | (idx, val) <- zip [0..] xs, even idx]

odds :: (WenToHouseMix a, Coercible a [Int]) => (Bin -> a) -> Int -> [Int]
odds br w = oddIndexedElements (coerce (br $ wenToHouseMix br w))

evens :: (WenToHouseMix a, Coercible a [Int]) => (Bin -> a) -> Int -> [Int]
evens br w = evenIndexedElements (coerce (br $ wenToHouseMix br w))

