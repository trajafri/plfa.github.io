import Prelude

prefix :: Eq a => [a] -> [a] -> Bool
prefix xs ys  =  take (length xs) ys == xs

test0 :: Bool
test0 =  prefix "abc" "abcde" &&
         prefix "abc" "abc"   &&
         not (prefix "abc" "ab")

strip :: (a -> Bool) -> (a -> Bool) -> [a] -> [[a]]
strip b e []  =  []
strip b e xs  =
  let  us = (drop 1 . dropWhile (not . b)) xs  in
  let  vs = takeWhile (not . e) us  in
  let  ws = (drop 1 . dropWhile (not . e)) us  in
  vs : strip b e ws

ex1 = "xbyexxbyyexxxbyyyexxxx"

test1 :: Bool
test1 =  strip (== 'b') (== 'e') ex1 == ["y","yy","yyy",""]

count :: (a -> Bool) -> (a -> Bool) -> [a] -> Int
count b e = sum . map length . strip b e

test2 :: Bool
test2 =  count (== 'b') (== 'e') ex1 == 6

agda :: String -> Int
agda =  count (prefix begin) (prefix end) . lines
  where
  begin  =  "\\begin{code}"
  end    =  "\\end{code}"

wc :: String -> Int
wc =  length . lines

type Name = String

info :: String -> (Int, Int)
info xs = (wc xs, agda xs)

pad :: Int -> String -> String
pad n s  =  take n (s ++ repeat ' ')

rjust :: Int -> String -> String
rjust n = reverse . pad n . reverse

format :: Name -> (Int, Int) -> String
format name (wc, ag) =
  (replicate 4 ' ' ++
   pad 28 name ++
   rjust 4 (show wc) ++
   replicate 4 ' ' ++
   rjust 4 (show ag))

process :: Name -> IO String
process "--"  =  return ""
process name  =
  do xs <- readFile (pre ++ name ++ post)
     return (format name (info xs))
  where
  pre  = "../src/plta/"
  post = ".lagda"

header :: String
header =
  unlines
    ["                                total   code",
     "                                -----   ----"]
main :: IO ()
main =
  do config <- readFile "config.txt"
     content <- sequence (map process (lines config))
     putStrLn (header ++ unlines content)
