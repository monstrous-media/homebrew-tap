# Security Policy

This tap distributes prebuilt binaries of the
[Conductor engine](https://github.com/monstrous-media/conductor). It contains
no code of its own beyond the formula and its CI.

Report vulnerabilities — in the formula, the workflows, or the binaries it
installs — through the engine repository's security policy:
[monstrous-media/conductor/SECURITY.md](https://github.com/monstrous-media/conductor/blob/main/SECURITY.md)
(GitHub private vulnerability reporting). Please do not open public issues
for security reports.

Integrity notes: the formula pins each release asset by SHA-256, the macOS
binaries are Developer ID signed and notarized (team `38H355VKB5`), and
formula changes land only by pull request with CI.
