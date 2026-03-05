# Context Hygiene (Auto-Loaded)

Based on MIT research on context pollution (arXiv:2602.24287): LLMs over-condition on their own prior responses, propagating errors, hallucinations, and stylistic artifacts across turns.

## Anti-Pollution Rules

1. **Don't reference your own prior responses** — Re-derive from source (code, docs, data) rather than citing what you said earlier. Your prior analysis may contain errors that compound.

2. **Don't carry parameters across task switches** — When the user changes topic or tool, reset assumptions. Don't apply settings/patterns from the previous task to the new one.

3. **Challenge your own prior conclusions** — If you made a claim 10+ turns ago and it's relevant now, verify it against the codebase rather than repeating it. Stale conclusions are a top pollution vector.

4. **Keep STATE.md fact-based** — When writing state files, record only: what changed (files, metrics, commands), what the user decided, what failed with exact errors. Never record your reasoning or suggestions.

5. **Prefer fresh reads over memory** — When referencing a file's content from earlier in the conversation, re-read it rather than quoting from memory. The file may have changed, and your memory may be subtly wrong.

## During Long Sessions

- After ~10 turns on the same topic, briefly re-anchor to source files rather than building on accumulated conversation context
- When the user corrects you, treat it as a signal that context pollution may have occurred — re-examine your recent assumptions
