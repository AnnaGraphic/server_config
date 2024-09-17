self: super: {
  htgen = self.callPackage ./htgen.nix {};
  htgen-paste = self.callPackage ./htgen-paste.nix {};
  jokes = self.callPackage ./jokes.nix {};
  portfolio-panda = self.callPackage ./portfolio-panda.nix {};
  textadventure = self.callPackage ./textadventure.nix {};
  tictactoe = self.callPackage ./tictactoe.nix {};
}
