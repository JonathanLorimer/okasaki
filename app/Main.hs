module Main where

import Criterion.Main ( defaultMain )
import Chapter2 ( ch2Group )

main :: IO ()
main = defaultMain
  [ ch2Group
  ]
