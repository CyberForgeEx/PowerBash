# Contributing to PowerBash

Thank you for your interest in contributing to PowerBash! We welcome contributions that help improve system administration scripting for both Windows and Linux environments. Please read these guidelines to ensure a smooth contribution process.

## Code of Conduct

Committed to providing a welcoming and inclusive environment for all contributors. Be respectful, professional, and constructive in all interactions.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally: `git clone https://github.com/yourusername/PowerBash.git`
3. **Create a new branch** for your work: `git checkout -b feature/your-feature-name`
4. **Make your changes** following our coding standards
5. **Test thoroughly** before submitting a pull request

## Contribution Types

acceptable contributions:

- **New Scripts**: Useful system administration scripts for Windows (PowerShell) or Linux (Bash)
- **Bug Fixes**: Corrections to existing scripts
- **Documentation**: Improvements to README, comments, or guides
- **Performance Improvements**: Optimizations to existing functionality
- **Testing**: Unit tests and integration tests

## General Guidelines

- **Comments**: Write clear, concise comments explaining why, not just what the code does
- **Modularity**: Break complex logic into reusable functions
- **Error Handling**: Provide meaningful error messages
- **Documentation**: Include inline comments and usage examples
- **Security**: Avoid hardcoding credentials, sanitize user input, validate parameters
- **Cross-platform awareness**: Clearly indicate if a script is Windows/Linux only
- **Testing**: Scripts must be tested on their target OS

## Naming Conventions

- **Windows scripts**: `Function-Name.ps1`
- **Linux scripts**: `function_name.sh`

## Pull Request Process

1. Submit your PR with a clear title and description
4. Respond to review comments promptly
5. Keep PRs focused; avoid mixing unrelated changes

## Documentation Requirements

Every new script must include:

- **Header comments** describing purpose
- **Error handling** explanation if non-obvious
- **README** entry with brief description and link

## Testing

- Test scripts on both clean and existing systems
- Verify error handling with invalid inputs
- Test with different user privilege levels

## Security Considerations

- Never include API keys, passwords, or connection strings
- Use appropriate OS security features (UAC for Windows, sudo for Linux)

---

Thank you for contributing to PowerBash! Your improvements make system administration easier for everyone.
