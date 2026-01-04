# Mistral Sysadmin Script (Sysdawg) - AI Context Guide

## Project Overview

**Sysdawg** is an AI-powered SRE (Site Reliability Engineering) copilot. It uses a locally hosted Mistral 7B model (running on "apollo") to diagnose system issues and provide advisory guidance on the local machine ("orion").

**Core Philosophy:**
- **Read-Only First:** AI is strictly an advisor; cannot execute commands autonomously
- **Safe by Design:** Never executes dangerous operations; always provides safe suggestions
- **Diagnostic Ladders:** Guides users through observation → narrowing → confirmation → suggestion pattern
- **Hard Context Limits:** Only passes relevant diagnostic data to reduce hallucinations
- **Persona-Driven:** Friendly, slightly paranoid junior sysadmin who prefers double-checking

## Current Implementation Status

### Active Features
- **Interactive Chat Mode:** Full REPL-style conversation with history (up to 10 turns)
- **One-Shot Query Mode:** Headless mode for scripting/automation (-p flag)
- **System Diagnostics:** Collects memory, disk, processes, uptime, and system status
- **SSH Integration:** Communicates with remote Mistral instance via SSH
- **Conversation State:** Maintains context across multiple exchanges
- **Read-Only Analysis:** Never executes commands; advisory-only responses

### Build and Setup

This is a pure Bash script with no build step required.

```bash
# Initial setup: Configure SSH to Mistral host
./setup-ssh.sh

# Interactive chat mode
./sysdawg

# One-shot query mode
./sysdawg -p "Why is my load average so high?"

# Help
./sysdawg --help
./sysdawg -h
```

## Architecture Overview

### File Structure
- `sysdawg`: Main executable (600+ lines) with dual-mode support
- `setup-ssh.sh`: SSH configuration helper for initial setup
- `.env`: Connection configuration file (not committed)
- `.env.example`: Example configuration template
- `SYSDAWG.md`: System prompt and persona definition for Mistral
- `commands.conf`: Configuration and safety rules (planned enhancement)
- `CLAUDE.md`: Detailed AI context documentation
- `CHANGELOG.md`: Version history
- `INSTRUCTIONS.md`: Development roadmap
- `IDEA.md`: Original design philosophy

### Configuration Storage
- `.env`: Stores APOLLO_HOST, APOLLO_USER, APOLLO_PORT, OLLAMA_API_URL
- Default values: apollo.local, current user, port 22
- SSH key authentication via system SSH setup

### Multi-Machine Architecture
```
orion (local user)
  |
  | SSH connection + diagnostics + prompt
  v
apollo (Mistral 7B instance)
  |
  | stdin/stdout communication
  v
Mistral 7B Model
  |
  | Analysis and advisory response
  v
Advice returned to user (NO execution)
```

## Core Implementation

### Main Execution Modes

**Interactive Chat Mode:**
1. Loads environment configuration from `.env`
2. Reads SYSDAWG.md persona definition
3. Collects initial system diagnostics
4. Enters conversation loop (up to 10 turns)
5. For each exchange:
   - Accepts user input
   - Optionally collects fresh diagnostics
   - Sends prompt + history to Mistral via SSH
   - Displays response and maintains history

**One-Shot Query Mode:**
1. Loads configuration
2. Collects system diagnostics
3. Builds prompt with query + diagnostics + persona
4. Sends to Mistral via SSH
5. Returns response to stdout
6. Exits without entering conversation loop

### Key Functions

**Configuration & Validation:**
- `check_env()`: Validates .env file exists with required variables
- `load_env()`: Sources environment variables with defaults
- `validate_ssh_connection()`: Tests SSH connectivity to apollo

**Diagnostic Collection:**
- `gather_diagnostics()`: Collects system state (df, free, uptime, etc.)
- Captures timestamp for diagnostics
- Includes memory usage, disk usage, processes, load average
- Optional extended diagnostics (journalctl, systemctl status)

**Communication:**
- `send_to_mistral()`: Builds prompt and sends to Mistral via SSH
- Handles stdin/stdout communication
- Formats response for user display
- Tracks conversation history

**Conversation Management:**
- `interactive_chat()`: Main chat loop managing user input/output
- `maintain_conversation_history()`: Stores up to 10 exchange turns
- Preserves context across multiple queries

**Command Safety (Planned Phase 3):**
- `check_command_safety()`: Validates commands against allowlist/blocklist
- Risk classification: SAFE / REVIEW / DANGEROUS
- Prevents execution of forbidden commands

### Diagnostic Data Collection

Currently collected:
- System information (uname, uptime)
- Memory status (free -h)
- Disk usage (df -h)
- Process information (ps aux, top summary)
- System logs (journalctl --no-pager, dmesg)
- Service status (systemctl status)
- Network information (netstat/ss)
- CPU load average

### Persona and Context

The SYSDAWG.md file defines:
- System prompt for Mistral model
- Personality traits (friendly, paranoid, cautious)
- Safety guidelines and constraints
- Diagnostic ladder methodology
- Response format preferences
- Confidence level indicators

## Safety Rules (Non-Negotiable)

### Allowed (Read-Only Commands)
- File reading: cat, less, head, tail, grep, awk, sed (without -i)
- File discovery: ls, stat, find
- Process monitoring: ps, top, htop, iotop
- System status: free, df, uptime, uname, dmesg
- Logging: journalctl --no-pager, systemctl status
- Network: netstat, ss, lsof

### Forbidden (Never Execute)
- Privileged: sudo, anything requiring elevation
- Destructive: rm, mv, cp into system directories
- Configuration changes: sed -i, sed -w, any -w flag
- Package management: apt, yum, pip, apt-get
- Service control: systemctl restart, systemctl stop
- Network changes: ifconfig, route, iptables
- Disk operations: mkfs, dd, fdisk
- Force operations: anything with --force, -F, or -i flags

## Development Roadmap

### Phase 1 (Current)
- Basic shell wrapper with diagnostics collection
- SSH communication to Mistral instance
- Interactive and one-shot modes
- Read-only advisory analysis

### Phase 2 (Planned)
- Structured output format
- Sections: Summary, Likely Causes, What to Check Next, Suggested Commands, Confidence Level
- Reduces hallucination through format constraints

### Phase 3 (Planned)
- Safety rails and command risk classifier
- Regex-based risk detection (SAFE / REVIEW / DANGEROUS)
- Prevents execution of forbidden commands
- Command allowlist and blocklist

### Phase 4 (Planned)
- Python migration for complex logic
- Modular collectors: power.py, network.py, storage.py, services.py
- YAML-based configuration
- Plugin-style architecture

### Phase 5 (Planned)
- Multi-device SSH tunneling
- Extend diagnostics across network fleet
- Device registry management

### Phase 6 (Planned)
- Web UI and dashboard
- Multi-device health visualization
- Container/process management
- Macro-based health checks

### Phase 7+ (Exploration)
- Automation of low-risk operations
- Safe command execution with safeguards
- Dry-run mode patterns

## Key Design Insights

1. **7B Models are Confidently Wrong:** Keep them constrained with narrow context and explicit formatting rules
2. **Context Quality Matters:** Passing only relevant diagnostics dramatically reduces hallucinations
3. **User Control:** Tool is advisory-only; user decides what to run
4. **Fail Safe:** If AI is wrong, nothing breaks; if user is wrong, they decide

## Configuration Example

```bash
# .env file structure
APOLLO_HOST=apollo.local
APOLLO_USER=jay
APOLLO_PORT=22
OLLAMA_MODEL=mistral
OLLAMA_API_URL=http://localhost:11434/api/chat
```

## Important Notes

1. Never commit `.env` files with credentials
2. Run setup-ssh.sh for initial configuration
3. Verify SSH connectivity before using interactive mode
4. Review SYSDAWG.md for model behavior guidelines
5. Always verify Mistral instance is running on apollo
6. Tool is design-locked for read-only operations (by architectural choice)

## Development Guidelines

1. **Testing:** Manual testing of interactive and one-shot modes
2. **SSH:** Ensure SSH connectivity to apollo works before changes
3. **Conversation State:** Be careful with history management
4. **Diagnostics:** Expand diagnostics cautiously (context limits matter)
5. **Safety:** Never add execution capabilities without explicit approval
