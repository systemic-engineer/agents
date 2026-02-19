-- Canonical OBC configuration for all agent invocations under systemic-engineer.
--
-- Local projects override specific fields in their own .obc/config.dhall:
--
--   let Canonical = https://raw.githubusercontent.com/systemic-engineer/agents/main/.obc/config.dhall
--   in Canonical // { budgets = Canonical.budgets // { nesting_max_levels = 4 } }

{ budgets =
    { -- Code structure
      nesting_max_levels = 2
    , function_arity_max = 5
    , module_line_max    = 300
    , function_line_max  = 20

      -- Agent behavior
    , chatter_interval_ms    = 30000   -- emit Agent_Chatter at least every 30s
    , question_timeout_ms    = 300000  -- escalate if no response in 5m
    , blocker_timeout_ms     = 600000  -- reassign if blocked >10m
    , max_files_per_commit   = 20      -- split larger changes across commits

      -- Safety
    , max_credential_age_s   = 3600    -- request new lease after 1h
    }

, observables =
    { -- What agents watch
      tdd_phase_enforcement   = True   -- commits must carry 🔴/🟢/♻️/🔀
    , coverage_enforcement    = True   -- push requires 100% coverage
    , credential_scope        = True   -- workers must not exceed granted scope
    , chatter_heartbeat       = True   -- agents must emit chatter within interval
    }

, cascades =
    { -- What happens when a budget is exceeded
      nesting_violation   = "emit Agent_Chatter with refactor suggestion"
    , missing_tdd_phase   = "reject commit"
    , coverage_gap        = "reject push"
    , scope_exceeded      = "emit Agent_Blocker and halt"
    , blocker_timeout     = "emit Agent_Decision and halt"
    }

, roles =
    { supervisor = ".obc/SUPERVISOR.md"
    , worker     = ".obc/WORKER.md"
    }
}
