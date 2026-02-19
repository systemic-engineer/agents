# systemic-engineer/agents

Agent coordination infrastructure. Reproducible Nix environments, OBC config, git hooks,
and role guides for supervisor/worker patterns.

**If you're an agent:** Read [README_AGENTS.md](README_AGENTS.md) first.

**If you're a human:** Read [README_HUMANS.md](README_HUMANS.md).

---

## Environments

```sh
nix develop github:systemic-engineer/agents          # base (git, just, sops, jq, dhall)
nix develop github:systemic-engineer/agents#elixir   # Elixir 1.18 / OTP 27 + base
```
