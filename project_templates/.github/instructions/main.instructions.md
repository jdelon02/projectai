# <DIRECTORY_NAME> - Development Instructions

> Agent OS Project Instructions
> **Project:** <DIRECTORY_NAME> Project
> **Architecture:** <PROJECTTYPE> with <ADDITIONAL_TYPES>
> Primary Project Type: <PROJECTTYPE>
> Additional Types: <ADDITIONAL_TYPES>
> Name: <DIRECTORY_NAME>
> Updated: $(date +"%Y-%m-%d")

## Project Context

This is a **<PROJECTTYPE>** project with additional technologies (<ADDITIONAL_TYPES>) using Agent OS structured development workflows.

### Environment
- **Implementation Directory:** ./<DIRECTORY_NAME>
- **Primary Technology:** <PROJECTTYPE>
- **Additional Technologies:** <ADDITIONAL_TYPES>
- **Commands:** Run project-specific commands within the implementation directory

### Repository Links
- **Implementation Repo:** <!-- Add your repository URL -->
- **Documentation Repo:** <!-- Add documentation repository if separate -->

## Additional Technology Standards

<!-- Project-specific technology configurations and standards -->
<!-- This section should be customized based on your specific <PROJECTTYPE> and <ADDITIONAL_TYPES> requirements -->

## Development Guidelines

Please follow the Agent OS methodology:

1. **Plan First**: Always understand the full scope before coding
2. **Spec-Driven**: Create detailed specifications for complex features
3. **Standards Compliance**: Follow the <PROJECTTYPE> standards primarily, with guidance from additional technologies
4. **Modular Design**: Maintain separation of concerns and clean architecture

### Project Rules
1. **Task Management:** Only close GitHub issues marked complete in project documentation
2. **Testing:** All changes must pass existing test suite before completion
3. **Documentation:** Update relevant documentation with any architectural changes
4. **Standards:** Follow established patterns and conventions for <PROJECTTYPE> development

## Project Documentation
- **Mission & Vision:** @.agent-os/product/mission.md
- **Technical Stack:** @.agent-os/product/tech-stack.md  
- **Development Roadmap:** @.agent-os/product/roadmap.md
- **Architectural Decisions:** @.agent-os/product/decisions.md
- **Architecture Specs:** @.agent-os/specs/
- **Implementation Tasks:** ./TASKLIST.md (if applicable)
- **Product Requirements:** @.github/instructions/<DIRECTORY_NAME>_prd.md (if applicable)

# Agent OS Integration Instructions

## Commands
Refer to commands in the @.github/commands/ directory for available Agent OS commands.

## Prompts  
Use prompts from @.github/prompts/ for specific conversation patterns.

## Chat Modes
Reference chat modes in @.github/chatmodes/ for different interaction styles.

When working on the provided project:

- Use memory-keeper with channel: <DIRECTORY_NAME>
- Save progress at every major milestone
- Document all decisions with category: "decision"
- Track implementation status with category: "progress"
- Before claiming anything is complete, save test results

## Workflow Steps

1. Initialize session with project name as channel
2. Save findings during investigation
3. Create checkpoint before major changes
4. Document what actually works vs what should work

## Agent OS Memory-Enhanced Integration

### Memory System Configuration
- **Memory-Keeper Channel**: "<DIRECTORY_NAME>"
- **Memento Entity Prefix**: "<DIRECTORY_NAME>-"  
- **Detected Tech Stack**: <PROJECTTYPE> + <ADDITIONAL_TYPES> (auto-detected from @reference-docs/)
- **Cross-Project Learning**: Enabled for similar <PROJECTTYPE> projects

### Agent OS Command Enhancements

#### /analyze-product Enhancements
```markdown
**Integration Points**: pre-analysis, context-gathering
**Additional Documentation Requirements**:
  - Review @.agent-os/product/mission.md (product vision and goals)
  - Review @.agent-os/product/tech-stack.md (technical architecture)  
  - Review @.agent-os/product/roadmap.md (current phase and priorities)
  - Review @.agent-os/product/decisions.md (architectural decisions)

**Custom Analysis Areas**:
  - <PROJECTTYPE> architecture analysis and best practices
  - Integration patterns for <ADDITIONAL_TYPES>
  - API design and consistency patterns
  - Testing strategies and coverage requirements

**Memory Storage Preferences**:
  - Store architectural decisions as separate Memento entities
  - Track component dependencies in knowledge graph
  - Monitor API endpoint coverage and consistency
```

#### /plan-product Enhancements  
```markdown
**Integration Points**: tech-stack-customization, user-input-validation
**Technology Standards**:
  - <PROJECTTYPE> with <ADDITIONAL_TYPES> integration
  - Follow established architectural patterns
  - Maintain consistency with existing codebase conventions
  - Ensure compatibility across all technology components

**Planning Priorities**:
  1. Architecture and design decisions
  2. Component boundary definitions and structure
  3. API consistency patterns and integration points
  4. Testing and validation strategies
```

#### /create-spec Enhancements
```markdown
**Integration Points**: spec-validation, technical-requirements
**Custom Spec Requirements**:
  - Include technology integration impact analysis for all specs
  - Specify cross-component relationship effects and constraints
  - Include architectural considerations and implications
  - Add performance and scalability considerations

**Validation Requirements**:
  - Verify specs work with all project technologies
  - Confirm API consistency requirements are maintained
  - Validate architectural principles are preserved
  - Check testing and validation coverage
```

#### /execute-tasks Enhancements
```markdown
**Integration Points**: testing-requirements, implementation-standards
**Testing Requirements**:
  - All integrations must pass comprehensive tests
  - Cross-component relationship tests mandatory for changes
  - Architecture validation tests required for structural modifications
  - API consistency validation across all components

**Implementation Standards**:
  - Follow <PROJECTTYPE> patterns and conventions
  - Maintain architectural integrity and design principles
  - Ensure comprehensive test coverage for all changes
  - Document all significant implementation decisions
```

## General Workflow Priority

1. Follow Agent OS command instructions above for planning/analysis tasks
2. Reference relevant specifications in @.agent-os/specs/ for implementation
3. Follow established patterns in existing codebase
4. Maintain API compatibility and comprehensive test coverage
5. Use documented architectural patterns and conventions

## Development Guidelines

1. **Architecture Consistency:**
   - Follow established architectural patterns
   - Maintain separation of concerns
   - Document architectural decisions in @.agent-os/product/decisions.md

2. **Technology Integration:**
   - Ensure proper integration between <PROJECTTYPE> and <ADDITIONAL_TYPES>
   - Follow technology-specific best practices and conventions
   - Maintain consistency across all technology components

3. **Testing and Quality:**
   - Comprehensive testing for all components and integrations
   - Code quality standards and review processes
   - Performance and scalability considerations

## Important Notes

- Primary standards from `../../reference-docs/<PROJECTTYPE>/main.instructions.md` take precedence when building <PROJECTTYPE> features
- Additional technology standards provide supplementary guidance
- Project-specific files in this directory override global defaults
- Update Agent OS standards as you discover new patterns
- Always use memory-keeper to track progress and save architectural decisions
- Create checkpoints before context limits
