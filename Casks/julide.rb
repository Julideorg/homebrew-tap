cask "julide" do
  arch arm: "aarch64", intel: "x64"

  version "0.3.1"
  sha256 arm:   "1b0e6e2038410def04a334a8ebd0791a763c1d22ec4e2d756fe431627b95a045",
         intel: "2cf7d64d94fa87bd2e68dd5a16aad91df5866dcec1bc8a97ff038572ebbb6932"

  url "https://github.com/Julideorg/JulIde/releases/download/v#{version}/julide_#{version}_#{arch}.dmg"
  name "julIDE"
  desc "IDE for the Julia programming language"
  homepage "https://github.com/Julideorg/JulIde"

  livecheck do
    url :url
    strategy :github_latest
  end

  # auto_updates: julIDE updates itself through tauri-plugin-updater, so brew must not
  # try to manage upgrades on its behalf.
  auto_updates true
  depends_on macos: :catalina

  app "julide.app"

  # julIDE is not code-signed or notarized yet, so the quarantine attribute Homebrew
  # applies would make Gatekeeper refuse to launch it. Clear it here and say so in the
  # caveats below. Remove this block once the app is signed and notarized.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/julide.app"]
  end

  zap trash: [
    "~/Library/Application Support/julide",
    "~/Library/Caches/com.ofek.julide",
    "~/Library/HTTPStorages/com.ofek.julide",
    "~/Library/Saved Application State/com.ofek.julide.savedState",
    "~/Library/WebKit/com.ofek.julide",
  ]

  caveats <<~EOS
    julIDE is not yet code-signed or notarized, so the macOS quarantine attribute
    was removed from #{appdir}/julide.app on your behalf.

    julIDE does not bundle Julia. You need Julia 1.6 or newer:
      brew install julia
  EOS
end
