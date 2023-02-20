{s}: rec
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:okasaki' --allow-eval --warnings";
  hoogleScript = s "hgl" "hoogle serve";
}
