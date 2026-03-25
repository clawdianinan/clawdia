# Claude-Qwen Development Best Practices

## 🎯 Core Principles

### 1. Zero-Cost Development
- Use local Qwen3.5:9b via Ollama
- No API costs for development work
- OpenClaw uses API models for orchestration only

### 2. Correct Command Usage
- **✅ CORRECT:** `ollama launch claude --model qwen3.5:9b`
- **❌ WRONG:** `claude --model qwen3.5:9b` (doesn't work)
- **❌ PROHIBITED:** Ollama in OpenClaw config

### 3. Agent Role Compliance
- **TRINITY:** Implementation & feature development
- **MORPHEUS:** QA & testing
- **CYPHER:** Security & hardening
- **SHURI:** Jira & documentation
- **CHIMAMANDA:** Slack & communications

## 🔧 Development Workflow

### Before Starting:
1. **Jira Ticket:** SHURI creates ticket (mandatory)
2. **Environment:** Run `validate-setup.sh`
3. **Task:** Use `task-template.md` for planning

### During Development:
1. **Launch:** Use standardized command or script
2. **Iterate:** Small, testable increments
3. **Test:** Immediate validation after changes
4. **Commit:** Descriptive GitHub commits

### After Completion:
1. **Deploy:** Netlify if applicable
2. **Notify:** CHIMANDA sends Slack update
3. **Document:** SHURI updates Jira ticket
4. **Review:** Quality check and lessons learned

## 💡 Prompt Engineering Tips

### Effective Prompts:
```
"Implement a React component that does X with Y props"
"Fix the bug in file Z where error occurs"
"Write tests for component A covering cases B, C, D"
```

### Context Provision:
- Provide relevant code snippets
- Include error messages
- Specify file paths
- Mention dependencies

### Iterative Approach:
1. Start with clear requirements
2. Generate initial implementation
3. Test immediately
4. Refine based on results
5. Repeat until satisfied

## 🚀 Performance Optimization

### For Qwen3.5:9b:
- **Model size:** 9B parameters
- **Memory:** ~6GB RAM recommended
- **Speed:** Faster than larger models
- **Quality:** Good for most development tasks

### Batch Processing:
- Work on related files together
- Keep context window focused
- Break large tasks into smaller ones
- Use iterative refinement

### Memory Management:
- Clear context between unrelated tasks
- Save intermediate results
- Use file references instead of pasting large code blocks
- Restart session if performance degrades

## 🔒 Security Practices

### Code Security:
- Never include secrets in prompts
- Validate generated code for vulnerabilities
- Use security scanning tools
- Follow principle of least privilege

### Data Privacy:
- Local processing only (no API calls)
- Qwen runs entirely on local machine
- No data sent to external services
- Compliance with data protection rules

## 📊 Quality Assurance

### Code Quality:
- Follow project coding standards
- Include appropriate comments
- Write maintainable code
- Document design decisions

### Testing:
- Write unit tests for new code
- Include integration tests
- Test edge cases
- Validate performance

### Review Process:
- Self-review before committing
- Peer review when possible
- Automated CI/CD checks
- Manual testing for critical paths

## 🔗 Integration with Platforms

### Jira Integration:
- Create ticket before work
- Update status during work
- Add comments with progress
- Close ticket after completion

### GitHub Integration:
- Descriptive commit messages
- Link commits to Jira tickets
- Use proper branching strategy
- Create PRs for major changes

### Slack Integration:
- Deployment notifications
- Milestone updates
- Issue alerts
- Team coordination

### Netlify Integration:
- Automatic deployments
- Preview deployments for PRs
- Production deployment verification
- Rollback capability

## ⚠️ Common Pitfalls & Solutions

### Pitfall 1: Wrong Command
**Symptom:** `claude --model qwen3.5:9b` not found
**Solution:** Use `ollama launch claude --model qwen3.5:9b`

### Pitfall 2: Model Not Loaded
**Symptom:** Slow response or errors
**Solution:** `ollama pull qwen3.5:9b` and wait for download

### Pitfall 3: Context Loss
**Symptom:** Forgetting previous instructions
**Solution:** Provide context in each prompt, save important info

### Pitfall 4: Quality Issues
**Symptom:** Generated code doesn't work
**Solution:** Be more specific, provide examples, iterate

## 📈 Continuous Improvement

### Feedback Loop:
1. Track what works well
2. Identify patterns of success
3. Document effective prompts
4. Share learnings with team

### Skill Development:
- Practice with different task types
- Learn model capabilities and limits
- Develop prompt templates
- Build reusable components

### Process Refinement:
- Streamline workflow steps
- Automate repetitive tasks
- Improve validation scripts
- Enhance documentation

## 🎯 Success Metrics

### Development Metrics:
- Code compiles without errors
- Tests pass
- Deployment successful
- No regressions introduced

### Process Metrics:
- Jira tickets created before work
- GitHub commits during work
- Slack notifications after work
- Documentation updated

### Quality Metrics:
- Code review feedback
- Bug rate
- Performance benchmarks
- User satisfaction

---

**Last Updated:** 2026-03-19
**Version:** 1.0
**Status:** Active - Follow these practices for optimal results