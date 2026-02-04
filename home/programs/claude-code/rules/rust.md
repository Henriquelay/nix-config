---
paths: "**/*.rs"
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
