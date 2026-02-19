# Template Justfile for systemic-engineer projects.
# Copy to your project and trim to what's relevant.
# Canonical source: systemic-engineer/agents/Justfile

# List all commands
default:
    @just --list

# ── Dependencies ────────────────────────────────────────────────────────────

# Fetch dependencies (Elixir projects)
deps:
    mix deps.get
    mix2nix > deps.nix

# ── Quality ─────────────────────────────────────────────────────────────────

# Run tests
test:
    mix test

# Run only tests affected by recent changes
test-stale:
    mix test --stale

# Check test coverage
coverage:
    mix coveralls

# Generate HTML coverage report
coverage-html:
    mix coveralls.html

# Run linter
lint:
    mix credo --strict

# Format code
format:
    mix format

# Run all quality checks
check:
    mix check

# ── Hooks ───────────────────────────────────────────────────────────────────

# Pre-commit gate: called by commit-msg hook. Stash isolation handled by the hook.
pre-commit: check

# Pre-push gate: called by pre-push hook. Enforce 100% coverage.
pre-push: coverage

# ── Secrets ─────────────────────────────────────────────────────────────────

# Start IEx with secrets loaded
iex:
    sops exec-env secrets.sops.yaml 'iex -S mix'

# ── Hooks installation ───────────────────────────────────────────────────────

# Install canonical hooks from systemic-engineer/agents
install-hooks:
    #!/usr/bin/env bash
    BASE="https://raw.githubusercontent.com/systemic-engineer/agents/main/hooks"
    curl -s -o .git/hooks/commit-msg "$BASE/commit-msg"
    curl -s -o .git/hooks/pre-push "$BASE/pre-push"
    chmod +x .git/hooks/commit-msg .git/hooks/pre-push
    echo "✓ Hooks installed from systemic-engineer/agents"
