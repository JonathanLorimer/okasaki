{s}: rec
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:okasaki' --allow-eval --warnings";
  replScript = s "repl" "cabal new-repl lib:okasaki";
  hoogleScript = s "hgl" "hoogle serve";
}
