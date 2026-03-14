# Skills Repository

This repository contains agent skills for investigation, planning, and specification work.

## Overview

- `investigator`: skill for repository research and technical analysis
- `planner`: skill for creating and managing ExecPlans
- `specifier`: skill for organizing software requirements and specifications

Each skill lives in its own directory and includes a `SKILL.md`, agent config, and supporting references.

## Installation

Install all skills into `~/.agents/skills` from the repository root:

```bash
./install.sh
```

Use a custom destination if needed:

```bash
./install.sh /path/to/destination
```

The script detects each top-level directory that contains a `SKILL.md` and syncs it with `rsync`, excluding `.git/` and `.DS_Store`.

## Skills

### Investigator

`investigator` is focused on repository investigation and analysis.

- Use cases: technical research, deep dives, root-cause analysis, background study
- Role: turns findings into structured investigation reports

### Planner

`planner` supports the creation and management of ExecPlans.

- Use cases: complex features, significant refactors, execution planning
- Role: structures implementation work before execution starts
- References:
  - [OpenAI Cookbook](https://cookbook.openai.com/articles/codex_exec_plans)
  - [YouTube](https://www.youtube.com/watch?v=Gr41tYOzE20)

### Specifier

`specifier` supports software requirements definition and specification drafting.

- Use cases: requirement definition, spec drafting, assumption and constraint management
- Role: converts requests or research into implementation-ready specifications

## License

MIT
