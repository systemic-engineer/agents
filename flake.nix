{
  description = "systemic-engineer/agents — reproducible environments for agent invocations";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Shared tools available in all environments
        baseTools = [
          pkgs.git
          pkgs.just
          pkgs.jq
          pkgs.sops
          pkgs.gnupg
          pkgs.curl
          pkgs.dhall
          pkgs.dhall-json
        ];

        # BEAM / Elixir stack
        beamPkgs = pkgs.beam.packages.erlang_27;
        elixir   = beamPkgs.elixir_1_18;

        elixirTools = [
          elixir
          pkgs.erlang_27
          pkgs.mix2nix
        ];

        baseShellHook = ''
          export LANG=en_US.UTF-8
        '';

        elixirShellHook = baseShellHook + ''
          export MIX_HOME=$PWD/.nix-mix
          export MIX_REBAR3=$PWD/.nix-mix/rebar3
          export HEX_HOME=$PWD/.nix-hex
          export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
        '';

      in {
        devShells = {
          # ── base ─────────────────────────────────────────────────────────────
          # Minimal agent environment: git, just, sops, jq, dhall.
          # Use this when the project provides its own language runtime.
          #
          #   nix develop github:systemic-engineer/agents#base
          default = pkgs.mkShell {
            buildInputs = baseTools;
            shellHook   = baseShellHook;
          };

          base = pkgs.mkShell {
            buildInputs = baseTools;
            shellHook   = baseShellHook;
          };

          # ── elixir ───────────────────────────────────────────────────────────
          # Elixir 1.18 / OTP 27 + base tools.
          # Use for any BEAM project without pinned deps.
          #
          #   nix develop github:systemic-engineer/agents#elixir
          elixir = pkgs.mkShell {
            buildInputs = baseTools ++ elixirTools;
            shellHook   = elixirShellHook;
          };
        };
      });
}
