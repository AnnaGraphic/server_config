self: super: {
  htgen = self.callPackage ./htgen.nix {};
  htgen-paste = self.callPackage ./htgen-paste.nix {};
  jokes = self.callPackage ./jokes.nix {};
  textadventure = self.callPackage ./textadventure.nix {};
  tictactoe = self.callPackage ./tictactoe.nix {};
}
