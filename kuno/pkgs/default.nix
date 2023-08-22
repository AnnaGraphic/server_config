self: super: {
  htgen = self.callPackage ./htgen.nix {};
  tictactoe = self.callPackage ./tictactoe.nix {};
}
