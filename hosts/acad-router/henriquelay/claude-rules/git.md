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
