# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **mistral-sysadmin-script** project — a read-only SRE copilot designed to leverage Mistral 7B as a junior sysadmin assistant. The tool runs on two machines:
- **orion** (Linux Mint client, where you interact)
- **apollo** (Ubuntu Server running Mistral 7B locally)

The goal is to create a safe, advisory-only system that helps diagnose infrastructure issues across a fleet of devices without executing dangerous commands.

## Core Principles

The project is built around these non-negotiable safety rules (from IDEA.md):

1. **Read-only by default** — The system never executes commands autonomously
2. **Command proposal + justification** — Every suggestion must include:
   - What it does
   - What could break
   - How to undo it
3. **Use checklists, not fixes** — Mistral excels at diagnostic ladders (observe → narrow → confirm → suggest), not jump-to-solution fixes
4. **Hard context limits** — Only pass relevant diagnostic snippets to reduce hallucinations

## Development Roadmap

The project is split into phases (from INSTRUCTIONS.md):

**Phase 1** (Current): Basic shell script wrapper that collects system diagnostics and sends them to Mistral 7B via SSH + stdin
- Simple bash script collecting: uname, uptime, free, df, journalctl
- Sends diagnostics + user question to Mistral
- Returns structured markdown advice (no execution)

**Phase 2**: Output discipline and structured responses
- Force Mistral to respond in sections: Summary, Likely Causes, What to Check Next, Suggested Commands, Confidence Level
- Reduces hallucination through format constraints

**Phase 3**: Safety rails and risk classification
- Regex-based command risk classifier (SAFE / REVIEW / DANGEROUS)
- Never execute forbidden commands (rm, sudo, mkfs, dd, iptables -F, etc.)

**Phase 4**: Scale from bash to Python when friction appears
- Modular collectors: power.py, network.py, storage.py, services.py
- YAML-based configuration
- Plugin-style architecture

**Phase 5**: Multi-device SSH tunneling from apollo to other network devices
- Extend diagnostics across the 5-device fleet
- Optional: CLI commands to manage device registry

**Phase 6**: Web UI, dashboard, container/process management
- Dashboard for multi-device health
- Remote Docker + systemd integration
- Macro-based health checks (cron-style)

**Phase ??**: Automation of low-risk operations (future exploration)

## Command Classes (Safety Boundary)

### Allowed (Read-Only)
```
cat, less, head, tail, grep, rg, awk, sed (no -i), ls, stat, find, ps, top, htop,
free, df, uptime, uname, dmesg, journalctl --no-pager, systemctl status,
iotop (read-only), lsof, netstat, ss
```

### Forbidden (Never Automated)
```
sudo, anything with -w/-i/--force, package managers (apt, yum, pip),
service restarts, network changes (ifconfig, route), disk ops (mkfs, dd, fdisk),
rm, mv, cp into system directories, iptables -F, systemctl restart/stop
```

## Key Design Insights

1. **7B models are confidently wrong** — Keep them constrained with narrow context and explicit formatting rules
2. **Context matters more than capability** — Passing only relevant logs/configs dramatically reduces hallucinations
3. **You stay in control** — The tool is advisory-only; you decide what to run
4. **Fail safe, not fail forward** — If Mistral is wrong, nothing breaks. If you're wrong, you're still the decision-maker.

## Multi-Machine Architecture

```
orion (you)
  |
  | ssh + sysdog CLI
  v
apollo (Mistral 7B instance)
  |
  | stdin/stdout (prompt + diagnostics)
  v
Mistral → analysis → advice (NO execution)
  |
  | Optional: apollo ssh → other devices
  v
(power, network, storage, services data)
```

Configuration will eventually use `.env` for device credentials (see INSTRUCTIONS.md Step 1).

## Future Considerations

- Command risk classifier should use allowlist + blocklist approach
- Dry-run mode pattern: even if execution is later enabled, use `set -o noclobber` and no pipes into shells
- "Dry-run mode" is safer than trying to automate with safeguards
- Tool should be designed to grow: start simple (bash), evolve to Python as scope increases
