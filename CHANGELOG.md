# Changelog

All notable changes to Mistral Sysadmin Script (Sysdawg) are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Phase 2: Structured output with formatted sections (Summary, Likely Causes, What to Check Next, Suggested Commands, Confidence Level)
- Phase 3: Safety rails and command risk classifier (SAFE / REVIEW / DANGEROUS)
- Phase 4: Python migration with modular collectors
- Phase 5: Multi-device SSH tunneling across network fleet
- Phase 6: Web UI and dashboard
- Phase 7: Automation of low-risk operations

## [0.2.0] - 2025-12-31

### Added
- Interactive chat mode with conversation history (up to 10 turns)
- Full REPL-style conversation support
- Improved diagnostics gathering
- Enhanced prompt building with context

### Changed
- Sysdawg script refactored for interactive chat capability
- Better conversation state management
- Improved error handling and logging

## [0.1.0] - 2025-12-24

### Added
- Read-only SRE copilot powered by Mistral 7B
- SSH configuration to remote Mistral instance (apollo)
- Basic diagnostic collection (system info, memory, disk, processes)
- One-shot query mode (-p flag)
- Interactive chat mode
- SSH setup helper script (setup-ssh.sh)
- Environment configuration (.env file)
- Command safety rules documentation
- SYSDAWG.md persona definition
- Safety-first architecture with read-only operations only

### Features
- Collects system diagnostics (uname, uptime, free, df, journalctl, systemctl status)
- Builds prompts with diagnostic context
- Sends to Mistral 7B via SSH for analysis
- Returns advisory suggestions without execution
- Supports two modes: interactive chat and headless one-shot
