Code review on recent changes. Do the following:

1. **Identify changes**: Run `git diff HEAD` to see unstaged changes, and `git diff --cached` for staged changes. If no uncommitted changes, use `git diff HEAD~1` to review the last commit.

2. **Launch code-reviewer agent**: Use the code-reviewer agent to review the identified changes for:
   - Correctness and logic errors
   - Security vulnerabilities (OWASP top 10)
   - Performance issues
   - Adherence to project conventions (check CLAUDE.md if present)
   - Code quality and maintainability

3. **Present findings**: Show results organized by severity (critical → minor). For each issue, include the file, line number, and a concrete fix suggestion.

4. **Summary**: Give an overall assessment — is this ready to commit/merge, or does it need fixes?
