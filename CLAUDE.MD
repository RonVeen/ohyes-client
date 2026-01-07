# CLAUDE.MD

This file provides context and guidance for Claude Code when working on this project.

## Project Overview

**Project Name:** ohyes-client
**Description:** A native macOS client to notify the user when an OhYes reminder is due
**Tech Stack:** Swift, macOS (Apple Silicon)
**Version Control:** GitHub

## Project Structure

```
[Add directory structure overview]
```

## Development Guidelines

### Code Style
- Follow Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Use Swift concurrency (async/await) where appropriate
- Prefer Swift's modern features and best practices
- Use SwiftUI for UI development

### Architecture
- [Describe architectural patterns used]
- [Key design decisions]

### Testing
- [Testing approach and requirements]
- [How to run tests]

### Build & Deploy
- Build using Xcode or xcodebuild command
- Target platform: macOS (Apple Silicon)
- Verify builds complete successfully before committing

## Common Tasks

### Setup
```bash
# Clone the repository
git clone [repository-url]
cd ohyes-client

# Open in Xcode
open *.xcodeproj
# or
open *.xcworkspace  # if using CocoaPods/SPM workspace
```

### Running Locally
- Open the project in Xcode
- Select your Mac (Apple Silicon) as the target device
- Press Cmd+R to build and run
- Or use: `xcodebuild -scheme [scheme-name] -destination 'platform=macOS'`

### Adding New Features
1. Create a feature branch from main: `git checkout -b feature/your-feature-name`
2. Implement your changes
3. Verify that the code compiles successfully before committing
4. Commit your changes to the feature branch
5. Push the feature branch to GitHub
6. Create a Pull Request for review 
## Important Context

### Key Files
- [List critical files and their purposes]

### Dependencies
- [Important dependencies to be aware of]

### Known Issues
- [Document any known issues or gotchas]

## Notes for Claude

### Workflow Requirements
- **ALWAYS work on feature branches** - Never make changes directly to main
- Before starting any feature work, create a new branch: `git checkout -b feature/feature-name`
- Verify compilation success before committing any code changes
- Follow the GitHub workflow: feature branch → commit → push → Pull Request

### Development Environment
- This is a native macOS application targeting Apple Silicon
- Use Swift best practices and modern Swift features
- Assume Xcode is the primary development environment
- Build verification is required before any commits
