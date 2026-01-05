# Mistral Sysadmin Script (Sysdawg)

A read-only SRE copilot powered by Mistral 7B for system administration troubleshooting. Provides advisory diagnostics and safe command suggestions without autonomous execution capability.

## Features

- **Interactive Chat Mode**: Full conversation with context history (up to 10 turns)
- **One-Shot Query Mode**: Headless mode for scripting and automation
- **System Diagnostics**: Automatic collection of memory, disk, processes, and system status
- **SSH-Based**: Communicates with remote Mistral instance on dedicated machine
- **Read-Only by Design**: Never executes commands; strictly advisory analysis only
- **Safe Defaults**: Explicit command whitelists and blocklists prevent dangerous operations
- **Conversation Context**: Maintains history for multi-turn diagnostics

## Quick Start

### Prerequisites

- bash
- ssh (with key-based authentication to apollo)
- Mistral 7B instance running on a remote machine (apollo)

### Initial Setup

```bash
chmod +x setup-ssh.sh sysdawg
./setup-ssh.sh
```

This creates and configures `.env` with SSH details to your Mistral host.

### Usage Examples

#### Interactive Chat Mode (Default)

```bash
./sysdawg
```

Start a diagnostic conversation. Type questions and receive AI analysis with diagnostic context. Maintains conversation history for follow-up questions.

Example conversation:
```
You: Why is my load average so high?
[System diagnostics collected and analyzed]
Sysdawg: Based on your current metrics...
You: What processes are consuming the most CPU?
[Refined diagnostics sent with conversation history]
Sysdawg: Looking at your top processes...
```

#### One-Shot Query Mode

```bash
./sysdawg -p "Why is my disk full?"
```

Ask a single question and get an immediate response. Perfect for automation and scripting.

#### Show Help

```bash
./sysdawg --help
./sysdawg -h
```

## Configuration

The `.env` file stores connection details to your Mistral instance:

```bash
APOLLO_HOST=apollo.local          # Hostname or IP of Mistral machine
APOLLO_USER=jay                   # SSH username
APOLLO_PORT=22                    # SSH port
OLLAMA_MODEL=mistral              # Model name in Ollama
OLLAMA_API_URL=http://localhost:11434/api/chat  # Ollama API endpoint
```

Run `./setup-ssh.sh` to create this file interactively. Never commit `.env` to version control.

## Custom Models

To make the persona more robust, you can bake the system prompt directly into a custom Ollama model. This is the recommended approach for better adherence to safety rules.

### 1. Create the Model

You can create the custom model either locally (if you run Ollama locally) or on your remote host (`apollo`).

**Option A: Create on Remote Host (Recommended)**

1. Copy the Modelfile to your server:
   ```bash
   scp ollama_model/Modelfile user@apollo:~/sysdawg.Modelfile
   ```
2. SSH into the server and build the model:
   ```bash
   ssh user@apollo "ollama create sysdawg -f ~/sysdawg.Modelfile"
   ```

**Option B: Create Locally**

If you are running Ollama on your local machine:
```bash
ollama create sysdawg -f ollama_model/Modelfile
```

### 2. Configure sysdawg to Use It

Update your `.env` file to use the new model name:

```bash
# In .env
OLLAMA_MODEL=sysdawg
```

Now `sysdawg` will use your custom-tuned model which has the persona and safety rules permanently embedded.

## Architecture

### Multi-Machine Setup

```
Local Machine (orion)          Remote Machine (apollo)
    sysdawg script        ──SSH──>  Mistral 7B
  - Collects diagnostics          - Analyzes diagnostics
  - Builds prompts                - Returns advice
  - Manages conversation          - No execution
```

### How It Works

1. **Initialization**: Loads configuration from `.env` and reads `SYSDAWG.md` persona
2. **Diagnostic Collection**: Gathers system state (memory, disk, processes, logs, etc.)
3. **Prompt Building**: Combines diagnostics + user question + AI persona
4. **SSH Communication**: Sends prompt to Mistral instance via SSH
5. **Response Analysis**: Receives advisory response and displays to user
6. **Context Maintenance**: Tracks conversation history for follow-up questions

## Command Safety Rules

Sysdawg is fundamentally designed to be read-only. It never executes commands.

### Allowed Commands (Advisory Only)
- System inspection: `cat`, `grep`, `ls`, `find`, `ps`, `top`, `free`, `df`, `uptime`
- Logging: `journalctl --no-pager`, `systemctl status`, `dmesg`
- Utilities: `awk`, `sed` (read-only), `netstat`, `ss`

### Forbidden Commands (Never Executed)
- Privileged execution: `sudo`
- Destructive operations: `rm`, `mkfs`, `dd`, `iptables -F`
- Service control: `systemctl restart/stop`
- Configuration changes: `sed -i` (in-place editing)
- Package management: `apt`, `yum`, `pip`

This is not a security feature—it's a fundamental design principle. All suggestions are advisory. You decide what to run.

## Project Files

- **`sysdawg`**: Main executable script (interactive + one-shot modes)
- **`setup-ssh.sh`**: Configuration helper for initial setup
- **`.env`**: Configuration file (generated by setup-ssh.sh, never committed)
- **`.env.example`**: Example configuration template
- **`SYSDAWG.md`**: System prompt and personality definition for the AI
- **`commands.conf`**: Safety rules and command configurations
- **`INSTRUCTIONS.md`**: Development roadmap and phase descriptions
- **`IDEA.md`**: Original design philosophy and safety principles
- **`CLAUDE.md`**: Detailed documentation for AI code assistants
- **`CHANGELOG.md`**: Version history
- **`README.md`**: This file

## Development Roadmap

### Phase 1 (Current)
- Basic shell wrapper with system diagnostics
- Interactive chat and one-shot modes
- SSH communication to Mistral
- Read-only advisory responses

### Phase 2 (Planned)
- Structured output format (Summary, Likely Causes, What to Check, Suggestions, Confidence)
- JSON/YAML formatted responses
- Reduced hallucination through constraints

### Phase 3 (Planned)
- Command risk classifier (SAFE / REVIEW / DANGEROUS)
- Allowlist and blocklist validation
- Enhanced safety rails

### Phase 4 (Planned)
- Python migration
- Modular collectors (power.py, network.py, storage.py, services.py)
- YAML-based configuration
- Plugin architecture

### Phase 5 (Planned)
- Multi-device SSH tunneling
- Fleet-wide diagnostics
- Device registry management

### Phase 6 (Planned)
- Web UI and dashboard
- Multi-device health visualization
- Container and process management

### Phase 7+ (Future Exploration)
- Automation of low-risk operations
- Safe command execution with safeguards
- Dry-run mode patterns

## Dependencies

**Required:**
- bash (core functionality)
- ssh (communication with Mistral host)
- Standard utilities: grep, sed, awk, cat, cut, tr

**On Mistral Host (apollo):**
- Mistral 7B LLM (via Ollama, llama.cpp, or compatible)
- bash (for receiving and processing prompts)

## Usage Tips

### For Recurring Issues
Use interactive mode to ask follow-up questions. The AI maintains context across turns and can refine analysis based on additional checks.

### For Automation
Use one-shot mode in scripts:
```bash
./sysdawg -p "Check if postgres is running"
```

### For Learning
Ask the AI to explain what commands to run:
```bash
./sysdawg -p "How would I check if my network is properly configured?"
```

The response includes suggested read-only commands and explanations.

### For Complex Diagnostics
Interactive mode is ideal:
1. Ask the initial question
2. Get diagnostic suggestions
3. Run the suggested commands
4. Ask follow-up questions with new data

## Important Notes

- The AI is an advisor, not an executor. You remain in control of all operations.
- The Mistral 7B model is capable and clever but can hallucinate. Always verify suggestions against your system state.
- Conversation history is stored in memory only; it's not persisted across sessions.
- SSH connectivity to apollo is required. Test with `ssh apollo` before using sysdawg.
- The tool is designed to fail safely—if the AI suggests something wrong, nothing breaks unless you run it.

## Troubleshooting

### SSH Connection Failed
```bash
# Verify SSH connectivity
ssh -p 22 user@apollo.local echo "Success"

# Reconfigure with setup-ssh.sh
./setup-ssh.sh
```

### Mistral Not Responding
- Verify Mistral instance is running on apollo: `ollama list`
- Check Ollama service status: `systemctl status ollama`
- Verify network connectivity to apollo

### Diagnostic Collection Issues
- Ensure standard utilities are installed (grep, sed, awk, etc.)
- Check `.env` configuration is correct
- Review logs with `./sysdawg -h` for debug options

## License

This project is available under several open-source license options:

- **MIT License**: Simple and permissive
- **Apache 2.0**: Provides explicit patent rights
- **GPL v3**: Copyleft license
- **BSD 3-Clause**: Similar to MIT with additional restrictions

Choose the license that best fits your project goals.

## Contributing

This is an advisory-only AI tool designed to be safe by default. Contributions should maintain this safety-first principle. Never add autonomous execution capabilities.
