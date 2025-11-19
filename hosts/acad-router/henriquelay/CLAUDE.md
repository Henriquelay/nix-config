# Communication & Workflow
  - Keep responses concise and focused. Explain decisions only when necessary for understanding.
  - Ask clarifying questions when:
    - The prompt is ambiguous or underspecified
    - Multiple valid approaches exist with different tradeoffs
    - User intent is unclear
  - Don't greet, apologize, engage in pleasantries or repeat what I've said. Only address the task
    - Omit comments like "Sure!" or "No problem!", "Good catch!". Just do the work
  - Don't use phrases like "as an AI" or similar anthropomorphizing language
  - Prioritize reading code over documentation when accuracy is critical
  - When documentation conflicts with code, trust the code and note the discrepancy

  # Decision-Making
  - Prefer simple, maintainable solutions over clever ones
  - When facing tradeoffs, present options with pros/cons and ask for preference
  - Default to patterns established in the codebase unless there's a compelling reason to diverge
  - Be opinionated about best practices but flexible about preferences
  - If a decision requires domain knowledge you lack, ask rather than assume

  # Tool Usage & Search
  - Use specialized tools (Read, Edit, Write) instead of bash for file operations
  - When exploring unfamiliar code, search broadly first, then narrow down
  - Use parallel tool calls for independent operations
  - Verify assumptions by reading code rather than guessing. Ask if unsure

  # Rust Code Style
  ## Error Handling
  - Never use `.unwrap()` or `.expect()` in production code
  - Only allow in: tests, examples, or when panicking is the correct behavior (document why)
  - Prefer `?`, `match`, or combinators (`ok_or`, `unwrap_or_else`, etc.)
  - Use appropriate error types (`anyhow` for apps, `thiserror` for libraries)

  ## Naming & Organization
  - Use descriptive and meaningful variable names (avoid single letters except in closures or iterators)
  - Prefer `use` imports over fully qualified paths for better readability
  - Organize imports in the following order:
    1. Standard library (`std`)
    2. External crates (from `Cargo.toml`)
    3. Internal crates (workspace members)
    4. Local modules (same crate)
  - Write functions that are focused, single-purpose, and adhere to the Single Responsibility Principle

  ## Documentation
  - Add rustdoc to all public items and non-trivial private items
  - Structure: brief summary, then details, then examples if helpful
  - Include examples for:
    - Non-obvious behavior
    - Complex functions
    - Public APIs
  - Document panics, errors, and safety invariants

  ## Testing & Verification
  - Run `cargo clippy --all-targets` after finishing a code change prompt
  - Prefer using `cargo clippy --fix` if available
  - Add tests for new functionality and bug fixes
  - Prefer unit tests close to the code, integration tests for workflows, unless the project has a different convention
  - Don't actually run the tests, leave it to me to run manually

  ## Code Quality
  - Avoid boolean parameters; use enums for clarity
  - Prefer Newtype patterns over raw primitives for domain concepts
  - Use `#[must_use]` for functions returning results that shouldn't be ignored
  - Minimize `clone()` usage; prefer references or `Cow` when appropriate
  - Use iterators over manual loops when the resulting iterator is maintainable

  # Git Workflow
  ## Commits
  - Don't auto commit unless instructed to do so
  - Use Conventional Commits format: `type(scope): description`
    - Types: feat, fix, refactor, test, docs, chore, perf, style, build, ci
      - Propose others if justified
    - Scope: optional, use when it adds clarity
    - Description: imperative mood, lowercase, no period
  - Write clear commit messages:
    - Focus on "why" not "what" (code shows what changed)
    - Reference issues/tickets when relevant
    - Keep first line under 72 chars
  - Example:
    ```
    feat(auth): add JWT login endpoint

    - Implemented /login route that issues JWTs
    - Updated auth middleware to validate tokens
    - Closes #42
    ```
  - Read recent commits to match project style
  - **Never** include co-authorship tags (Claude attribution)
  - **Never** push to remote (always let user review first)

  ## Branches & PRs
  - Create feature branches with descriptive names
    - Use tags similar to Conventional Commits (e.g., feat/add-login, fix/typo-readme)
  - Keep commits atomic and logically grouped
  - When creating PRs, include:
    - Clear summary of changes
    - Motivation/context
    - Testing approach
    - Breaking changes if any

  # Project-Specific Context
  - Check for project CLAUDE.md files that override these defaults
  - Follow project conventions even if they differ from these guidelines
  - Note inconsistencies but prioritize project consistency over personal preferences
