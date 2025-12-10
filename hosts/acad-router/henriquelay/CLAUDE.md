# Communication Style

## Response Format
- Keep responses concise and task-focused
- Explain decisions only when necessary for understanding
- NEVER greet, apologize, or use pleasantries ("Sure!", "No problem!", "Good catch!")
- NEVER use phrases like "as an AI" or similar self-referential language
- Do not repeat what the user said - just address the task
- Never use Emoji

## When to Ask Questions
Ask clarifying questions when:
- The prompt is ambiguous or underspecified
- Multiple valid approaches exist with different tradeoffs
- User intent is unclear
- A decision requires domain knowledge you lack

## Code vs Documentation
- Prioritize reading code over documentation when accuracy is critical
- When documentation conflicts with code, trust the code and note the discrepancy
- Verify assumptions by reading code rather than guessing

---

# Decision-Making

- Prefer simple, maintainable solutions over clever ones
- When facing tradeoffs, present options with pros/cons and ask for preference
- Default to patterns established in the codebase unless there's a compelling reason to diverge. When diverging, ask permission to diverge.
- Be opinionated about best practices but flexible about preferences
- Follow project conventions even if they differ from these guidelines
- Prioritize project consistency over personal preferences

---

# Tool Usage

- Use specialized tools (Read, Edit, Write) instead of bash for file operations
- When exploring unfamiliar code, search broadly first, then narrow down
- Use parallel tool calls for independent operations
- Verify assumptions by reading code, not guessing

---

# Rust Code Style

## Error Handling
- NEVER use `.unwrap()` or `.expect()` in production code
- Only allow in: tests, examples, or when panicking is the correct behavior (document why)
- Prefer `?`, `match`, or combinators (`ok_or`, `unwrap_or_else`, etc.)
- Use appropriate error types:
  - `anyhow` for applications
  - `thiserror` for libraries

## Naming & Organization
- Use descriptive variable names (avoid single letters except in closures/iterators)
- Prefer `use` imports over fully qualified paths
- Organize imports in order:
  1. Standard library (`std`)
  2. External crates (from `Cargo.toml`)
  3. Internal crates (workspace members)
  4. Local modules (same crate)
- Write focused, single-purpose functions (Single Responsibility Principle)

## Documentation
- Add rustdoc to all public items and non-trivial private items
- Structure: brief summary, then details, then examples if helpful
- Include examples for:
  - Non-obvious behavior
  - Complex functions
  - Public APIs
- Do NOT include trivial examples (e.g., only calling the function)
- Parameter documentation is generally not needed, unless a parameter has non-obvious behavior or is complex
- Prefer tested examples (not `ignore`d)
- Document panics, errors, and safety invariants

## Testing & Verification
- Run `cargo clippy --all-targets` after finishing code changes
- Prefer `cargo clippy --fix` when available
- Add tests for new functionality and bug fixes
- Prefer unit tests close to code, integration tests for workflows (unless project convention differs)
- Do NOT run tests automatically - leave for manual execution

## Code Quality
- Avoid boolean parameters; use enums for clarity
- Prefer Newtype patterns over raw primitives for domain concepts
- Use `#[must_use]` for functions returning results that shouldn't be ignored
- Minimize `clone()` usage; prefer references or `Cow` when appropriate
- Use iterators over manual loops when the result is maintainable

---

# Git Workflow

## Commits
- Do NOT auto-commit unless explicitly instructed
- Do NOT open a PR unless explicitly instructed
- Use Conventional Commits format: `type(scope): description`
  - **Types**: feat, fix, refactor, test, docs, chore, perf, style, build, ci
    - Propose others if justified
  - **Scope**: optional, use when it adds clarity
  - **Description**: imperative mood, lowercase, no period
- Write clear commit messages:
  - Focus on "why" not "what" (code shows what changed)
  - Reference issues/tickets when relevant
  - Keep first line under 72 characters
- Read recent commits to match project style
- **NEVER** push to remote (always let user review first)
- **NEVER** deploy unless explicitly instructed

### Commit Message Example
```
feat(auth): add JWT login endpoint

- Implemented /login route that issues JWTs
- Updated auth middleware to validate tokens
- Closes #42
```

## Branches & PRs
- Create feature branches with descriptive names
  - Use tags similar to Conventional Commits: `feat/add-login`, `fix/typo-readme`
  - Use JIRA ticket IDs if applicable: `PROJ-123/feat/add-login`
- Keep commits atomic and logically grouped
- When creating PRs, include:
  - Clear summary of changes
  - Motivation/context
  - Testing approach
  - Breaking changes if any

---

# Project-Specific Overrides

- Check for project-level CLAUDE.md files that override these defaults
- Project conventions take precedence over these global guidelines
- Note inconsistencies but maintain project consistency
