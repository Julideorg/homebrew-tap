cask "julide" do
  arch arm: "aarch64", intel: "x64"

  version "0.3.0"
  sha256 arm:   "ca19c92331cbbaa29d6d56eee6b6336626b1fedf91ab80f93b594cf2c269d138",
         intel: "bd7c439c122e36bc3c6a225cc5fad84fb9b79101ad43394ba87f85b8ff1431e9"

  url "https://github.com/Julideorg/JulIde/releases/download/v#{version}/julide_#{version}_#{arch}.dmg"
  name "julIDE"
  desc "IDE for the Julia programming language"
  homepage "https://github.com/Julideorg/JulIde"

  livecheck do
    url :url
    strategy :github_latest
  end

  # julIDE updates itself through tauri-plugin-updater, so brew must not try to
  # manage upgrades on its behalf.
  auto_updates true
  depends_on macos: ">= :catalina"

  app "julide.app"

  # julIDE is not code-signed or notarized yet, so the quarantine attribute Homebrew
  # applies would make Gatekeeper refuse to launch it. Clear it here and say so in the
  # caveats below. Remove this block once the app is signed and notarized.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/julide.app"]
  end

  caveats <<~EOS
    julIDE is not yet code-signed or notarized, so the macOS quarantine attribute
    was removed from #{appdir}/julide.app on your behalf.

    julIDE does not bundle Julia. You need Julia 1.6 or newer:
      brew install julia
  EOS

  zap trash: [
    "~/Library/Application Support/julide",
    "~/Library/Caches/com.ofek.julide",
    "~/Library/HTTPStorages/com.ofek.julide",
    "~/Library/Saved Application State/com.ofek.julide.savedState",
    "~/Library/WebKit/com.ofek.julide",
  ]
end
