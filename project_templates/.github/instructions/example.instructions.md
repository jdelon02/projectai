# Civility Platform - Development Instructions

> Agent OS Project Instructions
> **Project:** Civility Social Media Platform
> **Architecture:** Laravel 12.x API + Next.js Frontend
> Primary Project Type: laravel
> Additional Types: mongodb, neo4j, influxdb, redis
> Name: civildiy
> Updated: 2025-08-27

## Project Context

This is a **Laravel 12.x** social media platform project with hybrid database architecture (MySQL, MongoDB, Neo4j) and modular activity system, using Agent OS structured development workflows.

### Environment
- **Implementation Directory:** ./civility-app (Laravel backend)
- **Database Architecture:** Hybrid database architecture with local network instances
  - **MySQL:** Core authentication, permissions, module registry (local network)
  - **MongoDB:** Activity content, flexible schemas (local network)
  - **Neo4j:** Social relationships, recommendations (local network)
- **Commands:** Run php/artisan/composer within ./civility-app directory

### Repository Links
- **Implementation Repo:** https://github.com/jdelon02/civildiy.com
- **Documentation Repo:** https://github.com/jdelon02/civility-docs

## Additional Technology Standards

### Database Configuration
- **MySQL Connection:** Direct connection to local network MySQL server
  ```
  DB_CONNECTION=mysql
  DB_HOST=localhost  # Or specific IP on local network
  DB_PORT=3306
  DB_DATABASE=civility
  ```
- **MongoDB Connection:** Direct connection to local network MongoDB server
  ```
  MONGODB_URI=mongodb://localhost:27017  # Or specific IP on local network
  MONGODB_DATABASE=civility_activities
  ```
- **Neo4j Connection:** Direct connection to local network Neo4j server
  ```
  NEO4J_HOST=localhost  # Or specific IP on local network
  NEO4J_PORT=7687
  NEO4J_DATABASE=civility_social
  ```

## Development Guidelines

Please follow the Agent OS methodology:

1. **Plan First**: Always understand the full scope before coding
2. **Spec-Driven**: Create detailed specifications for complex features
3. **Standards Compliance**: Follow the Laravel standards primarily, with guidance from additional technologies
4. **Modular Design**: Maintain separation of concerns and clean architecture

### Project Rules
1. **Task Management:** Only close GitHub issues marked complete in TASKLIST.md
2. **Testing:** All changes must pass existing test suite before completion
3. **Database Access:** All database connections must use local network instances, not Docker containers
4. **Package Management:** New modules must follow the modular package architecture pattern

## Project Documentation
- **Mission & Vision:** @.agent-os/product/mission.md
- **Technical Stack:** @.agent-os/product/tech-stack.md  
- **Development Roadmap:** @.agent-os/product/roadmap.md
- **Architectural Decisions:** @.agent-os/product/decisions.md
- **Architecture Specs:** @.agent-os/specs/
- **Implementation Tasks:** ./TASKLIST.md
- **Product Requirements:** @.github/instructions/civildiy_prd.md

# Agent OS Integration Instructions

## Commands
Refer to commands in the @.github/commands/ directory for available Agent OS commands.

## Prompts  
Use prompts from @.github/prompts/ for specific conversation patterns.

## Chat Modes
Reference chat modes in @.github/chatmodes/ for different interaction styles.

When working on the provided project:

- Use memory-keeper with channel: civildiy
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
- **Memory-Keeper Channel**: "civildiy"
- **Memento Entity Prefix**: "civildiy-"  
- **Detected Tech Stack**: Laravel + MongoDB + Neo4j + Redis + InfluxDB (auto-detected from @reference-docs/)
- **Cross-Project Learning**: Enabled for similar Laravel hybrid-database projects

### Agent OS Command Overrides

#### /analyze-product Enhancements
```markdown
**Integration Points**: pre-analysis, context-gathering
**Additional Documentation Requirements**:
  - Review @.agent-os/product/mission.md (product vision and goals)
  - Review @.agent-os/product/tech-stack.md (technical architecture)  
  - Review @.agent-os/product/roadmap.md (current phase and priorities)
  - Review @.agent-os/product/decisions.md (architectural decisions)


**Custom Analysis Areas**:
  - Hybrid database integration patterns (MySQL + MongoDB + Neo4j)
  - Laravel modular package architecture analysis
  - Cross-database relationship mappings and consistency
  - API authentication flows across multiple data stores

**Memory Storage Preferences**:
  - Store database relationships as separate Memento entities
  - Track module interdependencies in knowledge graph
  - Monitor API endpoint coverage across all databases
```

#### /plan-product Enhancements  
```markdown
**Integration Points**: tech-stack-customization, user-input-validation
**Technology Standards**:
  - Laravel 12.x with hybrid database architecture (MySQL + MongoDB + Neo4j)
  - Local network database connections (not Docker containers)
  - Modular package architecture pattern requirements
  - Cross-database user ID consistency patterns

**Planning Priorities**:
  1. Database integration architecture decisions
  2. Module boundary definitions and package structure
  3. API consistency patterns across multiple data stores
  4. Authentication/authorization flow across hybrid architecture
```

#### /create-spec Enhancements
```markdown
**Integration Points**: spec-validation, technical-requirements
**Custom Spec Requirements**:
  - Include database integration impact analysis for all specs
  - Specify cross-database relationship effects and constraints
  - Include module boundary considerations and package implications
  - Add performance implications for hybrid architecture decisions

**Validation Requirements**:
  - Verify specs work across all three database systems
  - Confirm API consistency requirements are maintained
  - Validate module isolation principles are preserved
  - Check authentication flow coverage across data stores
```

#### /execute-tasks Enhancements
```markdown
**Integration Points**: testing-requirements, implementation-standards
**Testing Requirements**:
  - All database connections must pass integration tests
  - Cross-database relationship tests mandatory for any changes
  - Module isolation tests required for package modifications
  - API consistency validation across all data stores

**Implementation Standards**:
  - Follow Laravel 12.x patterns exclusively
  - Use local network database connections (no Docker)
  - Maintain modular package architecture integrity
  - Ensure cross-database transaction safety
```

## General Workflow Priority

1. Follow Agent OS command instructions above for planning/analysis tasks
2. Reference relevant specifications in @.agent-os/specs/ for implementation
3. Follow established patterns in existing codebase
4. Maintain API compatibility and comprehensive test coverage
5. Use local network database connections for all database operations

## Database Development Guidelines

1. **Local Network Databases:**
   - All database connections must use local network instances
   - No Docker-based database containers should be used
   - Connection information is in @.agent-os/product/tech-stack.md

2. **Hybrid Database Architecture:**
   - MySQL: Core authentication, users, permissions, module registry
   - MongoDB: Activity content, flexible schemas, feed data
   - Neo4j: Social relationships, trusted circles, recommendations

3. **Cross-Database Relationships:**
   - User IDs as consistent identifiers across databases
   - MongoDB models reference MySQL user IDs
   - Neo4j nodes map to MySQL user records
   - See @.agent-os/product/decisions.md for architectural details

## Important Notes

- Primary standards from `../../reference-docs/laravel/main.instructions.md` take precedence when building Laravel features
- Additional technology standards provide supplementary guidance
- Project-specific files in this directory override global defaults
- Update Agent OS standards as you discover new patterns
- Always use memory-keeper to track progress and save architectural decisions
- Create checkpoints before context limits
