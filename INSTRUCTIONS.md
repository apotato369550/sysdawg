Alright. I have Mistral 7b running on a gaming PC called apollo (Ubuntu Server), and I'm running on a pc called orion (Linux Mint)

I want to utilize Mistral 7b and create a Claude-code-esque like deal, but for sys ad work. I have 6 devices in total (5 end devices, one managed switch) that I'd want

The credentials for this CLI tool should be found in an .env file, and more devices can be added w/ appropriate ssh credentials in case we want to ssh into them FROM apollo

step 1:
communication from orion to apollo's mistral 7b (dialogue) automated through an .sh script
basic i/o cli

step 2:
let mistral perform basic NON DESTRUCTIVE commands (see IDEA.md) to diagnose systems, neofetch maybe
enhanced cli (see claude code, codex, gemini)

step 3:
experiment with having apollo ssh into other devices into the network and performing diagnostics there
maybe include a '/' command to add a device or two
include a macro to ask help from more capable llms like claude or gemini on headless mode

step 4:
web ui and dashboard?
ALSO! to manage docker containers & system processes remotely w/ the AI as a sort-of virtual assistant, querying devices every now and then like a macro or cron job

step ??:
automate dangerous stuff idk (risky, too far off, but something i want to experiment w/ at some point)


see the vision? I'm excited :3

