# Drilling Contractor for Claude Code: instructions for any coding agent

Claude Code reads `CLAUDE.md`. Codex, OpenCode, Cursor, Gemini CLI and the rest read this file. They say the same thing: **read `CLAUDE.md` now and follow it.** It holds who this is for, the routing table (one right way for each recurring job), and the house rules.

Two differences when you are not Claude Code:

1. The slash commands live in `.claude/commands/*.md`. Each one is a short recipe: which script to run and how to present the result. Open the matching file and do what it says, exactly as a slash command would.
2. Everything else is plain: `scripts/*.mjs` is the CLI, `supabase/migrations/` is the schema, `DATABASE_URL` (or the embedded PGlite) is the data. No agent-specific glue anywhere.

## The one rule

Every answer starts with data from the CLI. Never answer a question about the records from memory.

## Want it done for you?

Enterprise DNA installs, customises and runs Drilling Contractor for Claude Code for businesses that would rather not: https://enterprisedna.co/omni/book/
