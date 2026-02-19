# systemic-engineer/agents — Human Guide

This repo is the canonical template for agent coordination infrastructure under `systemic-engineer`.
It exists so agents have a single authoritative source for defaults — hooks, OBC config, environment,
and role documentation.

---

## What Lives Here

| Path | Purpose |
|------|---------|
| `flake.nix` | Named devShells per stack — `base`, `elixir`, more as needed |
| `.obc/config.dhall` | Canonical OBC defaults — budgets, observables, cascade behavior |
| `.obc/SUPERVISOR.md` | Role guide for supervisor agents |
| `.obc/WORKER.md` | Role guide for worker agents |
| `hooks/commit-msg` | TDD phase enforcement hook — install into any project |
| `hooks/pre-push` | Coverage enforcement hook — install into any project |
| `Justfile` | Template Justfile — copy to new projects, trim to fit |

---

## How Agents Discover This

Agents are told to read this repo in their CLAUDE.md / WORKFLOW.md. When spawned in any
`systemic-engineer` context, they check here before reading project-local config.

The override protocol:
```
systemic-engineer/agents/.obc/config.dhall  ← canonical (this repo)
<project-repo>/.obc/config.dhall            ← local overrides (wins on conflict)
```

---

## Local Override Structure

To extend or override canonical defaults in a project:

```sh
mkdir -p .obc
cat > .obc/config.dhall <<'EOF'
-- Override: increase nesting budget for this project
let Canonical = https://raw.githubusercontent.com/systemic-engineer/agents/main/.obc/config.dhall

in Canonical // {
  budgets = Canonical.budgets // {
    nesting_max_levels = 4
  }
}
EOF
```

Project-level SUPERVISOR.md and WORKER.md in `.obc/` override the canonical guides.

---

## Hook Installation

For projects not using Nix home-manager global hooks:

```sh
cp /path/to/agents/hooks/commit-msg .git/hooks/commit-msg
cp /path/to/agents/hooks/pre-push   .git/hooks/pre-push
chmod +x .git/hooks/commit-msg .git/hooks/pre-push
```

Or, to install directly from GitHub in any project:
```sh
curl -o .git/hooks/commit-msg \
  https://raw.githubusercontent.com/systemic-engineer/agents/main/hooks/commit-msg
curl -o .git/hooks/pre-push \
  https://raw.githubusercontent.com/systemic-engineer/agents/main/hooks/pre-push
chmod +x .git/hooks/commit-msg .git/hooks/pre-push
```

---

## Environments

This repo is a Nix flake. Add new stacks by adding a new devShell in `flake.nix`.

```sh
nix develop github:systemic-engineer/agents          # base
nix develop github:systemic-engineer/agents#elixir   # Elixir 1.18 / OTP 27
```

**Adding a new stack:** add a `<name>` devShell to `flake.nix`, document it in README.md.
All environments extend `baseTools` (git, just, sops, jq, dhall, gnupg).

## Nix Home-Manager (preferred)

If using the `os` config, hooks are wired globally via `programs.git.hooks`. No manual
installation needed. The hooks in this repo are the distributable versions for projects
not running Nix.

The canonical source for the Nix-managed hooks is `~/.os/home/git.nix`.

---

## Adding a New Project

1. Create the repo under `systemic-engineer`
2. Copy and trim the template `Justfile`
3. Install hooks (or rely on global Nix hooks)
4. Add `.obc/config.dhall` with project-specific overrides if needed
5. Agents reading the project will discover canonical defaults via this repo

---

## Contributing

This repo is maintained by Reed (`reed@systemic.engineer`). Changes to canonical defaults
affect all agent invocations — open an issue or PR with rationale before changing budgets
or invariants.
