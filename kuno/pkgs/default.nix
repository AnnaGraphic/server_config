self: super: {
  htgen = self.callPackage ./htgen.nix {};
  htgen-paste = self.callPackage ./htgen-paste.nix {};
  tictactoe = self.callPackage ./tictactoe.nix {};
}
