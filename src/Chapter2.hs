{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE KindSignatures #-}
module Chapter2 where

import Data.Kind ( Type )
import Data.Maybe
import Criterion.Main

class Stack (f :: Type -> Type) where
  stackEmpty :: f a
  isEmpty :: f a -> Bool
  cons :: a -> f a -> f a
  head :: f a -> Maybe a
  tail :: f a -> f a

instance Stack [] where
  stackEmpty = []

  isEmpty [] = True
  isEmpty _ = False

  cons = (:)

  head = listToMaybe

  tail = Prelude.tail

-- Exercise 2.1
suffixes :: [a] -> [[a]]
suffixes [] = [[]]
suffixes (x:xs) = (x:xs) : suffixes xs

-- suffixes [1, 2, 3, 4]
-- [1, 2, 3, 4] : (suffixes [2, 3, 4])
-- [1, 2, 3, 4] : ([2, 3, 4] : (suffixes [3, 4]))
-- [1, 2, 3, 4] : ([2, 3, 4] : ([3, 4] : (suffixes [4])))
-- [1, 2, 3, 4] : ([2, 3, 4] : ([3, 4] : ([4] : suffixes [])))
-- [1, 2, 3, 4] : ([2, 3, 4] : ([3, 4] : ([4] : [])))
-- [[1, 2, 3, 4], [2, 3, 4], [3, 4], [4] , []]
--
-- Therefore linear time in the number of elements in the list (actually N + 1 for the [] constructor)
-- Also linear in the number of copies of the list that need to be made (also N + 1)
-- to populate the top level list

--- $> suffixes @Int [1, 2, 3, 4]

data Tree a = Empty | Full (Tree a) a (Tree a)
  deriving Show

treeInsert :: Ord a => Tree a -> a -> Tree a
treeInsert Empty a = Full Empty a Empty
treeInsert t@(Full tl x tr) a
  | a == x = t
  | otherwise = if a < x
     then Full (insert tl a) x tr
     else Full tl x (insert tr a)

treeMember :: Ord a => Tree a -> a -> Bool
treeMember Empty _ = False
treeMember (Full tl a tr) searchTerm
  | a == searchTerm = True
  | otherwise =
      if a < searchTerm
         then member tr searchTerm
         else member tl searchTerm

class Set (f :: Type -> Type) where
  setEmpty :: Ord a => f a
  insert :: Ord a => f a -> a -> f a
  member :: Ord a => f a -> a -> Bool

instance Set Tree where
  setEmpty = Empty
  insert = treeInsert
  member = treeMember

fromList :: Ord a => [a] -> Tree a
fromList [] = Empty
fromList (x:xs) = treeInsert (fromList xs) x

--- $> fromList [1, 6, 6, 3, 5, 4, 2]

-- Exercise 2.2
fastMember :: Ord a => Tree a -> a -> Bool
fastMember tree searchTerm = go tree searchTerm Nothing
  where
    go :: Ord a => Tree a -> a -> Maybe a -> Bool
    go Empty _ Nothing = False
    go Empty a (Just candidate) = a == candidate
    go (Full tl x tr) a m =
      if x < a
        then go tr a m
        else go tl a (pure a)

--- $> fastMember @Int (fromList [1, 6, 6, 3, 5, 4, 2]) 7
--
--- $> fastMember @Int (fromList [1, 6, 6, 7, 3, 5, 4, 2]) 6

-- Exercise 2.3

compactInsert :: Ord a => Tree a -> a -> Tree a
compactInsert Empty a = Full Empty a Empty
compactInsert tree a = go id tree
  where
    -- go :: forall a . Ord a => (Tree a -> Tree a) -> Tree a -> Tree a
    go apply Empty = apply $ Full Empty a Empty
    go apply (Full left v right)
      | a < v = go (\t -> apply $ Full t v right) left
      | a > v = go (\t -> apply $ Full left v t) right
      | otherwise = tree

-- Exercise 2.4

fastCompactInsert :: Ord a => Tree a -> a -> Tree a
fastCompactInsert = undefined

-- Exercise 2.5
-- create a tree with depth `Int`
complete :: Ord a => Int -> a -> Tree a
complete = undefined

-- Exercise 2.5


-- Exercise 2.6

treeSample :: Tree Int
treeSample = fromList [0,2..20_000]

ch2Group :: Benchmark
ch2Group =
  bgroup "persistence"
    [ bench "treeInsert"  $ whnf (treeInsert treeSample) 11_021
    , bench "treeMember"  $ whnf (treeMember treeSample) 11_020
    , bench "fastMember"  $ whnf (fastMember treeSample) 11_020
    , bench "compactInsert"  $ whnf (compactInsert treeSample) 11_021
    , bench "fastCompactInsert"  $ whnf (fastCompactInsert treeSample) 11_021
    ]
