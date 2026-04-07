{ pkgs }:
pkgs.callPackage ../flakes/llm-agents.nix/packages/pi/package.nix {
  inherit (pkgs.callPackage ../flakes/llm-agents.nix/lib/fetch-npm-deps.nix {})
    fetchNpmDepsWithPackuments npmConfigHook;
}
