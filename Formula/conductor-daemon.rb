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
      url "https://github.com/monstrous-media/conductor/releases/download/v0.1.0/conductor-daemon-aarch64-apple-darwin.tar.gz"
      sha256 "8e879ccc66389b8273f72198a9da06fded88ccb6233d9f24fb1bed0c1ecd19e0"
    end
    on_intel do
      url "https://github.com/monstrous-media/conductor/releases/download/v0.1.0/conductor-daemon-x86_64-apple-darwin.tar.gz"
      sha256 "de2adf7bbff2adc1f8602490dc3be95df3b8d0d8d71ba910501cbdbd7c352a0d"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/monstrous-media/conductor/releases/download/v0.1.0/conductor-daemon-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a7773a23b8c298939237c1878743517c5e36a333e3fcdf019f6ee933f8d28a5f"
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
