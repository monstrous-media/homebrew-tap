# Copyright 2025-2026 Monstrous Media
# SPDX-License-Identifier: MIT

# Binary formula on purpose: it repackages the GitHub release tarballs so the
# macOS binaries keep their Developer ID signature and notarization — a brew
# source build would produce unsigned ones. Bump: update the three url/sha256
# pairs from the new release's .sha256 assets — the version is scanned from
# the URLs (monstrous-media/conductor#79).
class ConductorDaemon < Formula
  desc "Multi-protocol input mapping engine daemon and control CLI"
  homepage "https://getconductor.app"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/monstrous-media/conductor/releases/download/v0.2.0/conductor-daemon-aarch64-apple-darwin.tar.gz"
      sha256 "42bc53bea5d55306f8e824fea5d36781e7c551fd57abf8b9c16f42cba3beeafb"
    end
    on_intel do
      url "https://github.com/monstrous-media/conductor/releases/download/v0.2.0/conductor-daemon-x86_64-apple-darwin.tar.gz"
      sha256 "27ff2a307066a176b7299bab19b88a2ff4a99e69e20d70143bea918f46a4def9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/monstrous-media/conductor/releases/download/v0.2.0/conductor-daemon-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "3f378518f2ba79f05eec75efbb3788a51d2c50311bdd09f3691ffce7d33f7c3b"
    end
  end

  def install
    bin.install "conductor"
    bin.install "conductorctl"
    # License/attribution files ship in tarballs from v0.1.1 onward
    # (monstrous-media/conductor#80); v0.1.0 tarballs are binaries-only.
    doc.install Dir["LICENSE", "NOTICE", "THIRD_PARTY_LICENSES.md"]
  end

  def caveats
    <<~EOS
      This installs the open-source Conductor engine:
        conductor     — the mapping daemon
        conductorctl  — the control CLI

      It is unrelated to the "conductor" Homebrew cask (conductor.build).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/conductor --version")
    assert_match version.to_s, shell_output("#{bin}/conductorctl --version")

    # Daemon-free config validation exercises real engine code paths.
    (testpath/"min.toml").write <<~TOML
      [[endpoints]]
      alias = "test-device"
      direction = "Input"
      type = "Matcher"
      matchers = [{ type = "NameContains", value = "Test Device" }]

      [[modes]]
      name = "Default"
    TOML
    output = shell_output("#{bin}/conductorctl validate-schema --config #{testpath}/min.toml")
    assert_match "Config is valid", output
  end
end
