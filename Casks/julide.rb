cask "julide" do
  arch arm: "aarch64", intel: "x64"

  version "0.5.0"
  sha256 arm:   "a8d42bdecb6ddf2cc8747e929ac747c42d10f8e604ba708763e1d1c87d01f524",
         intel: "86405f3e4bbae5d2fd551cdbe3fdab5c039d9190f0e9f5d0462a3dd66ee31aca"

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
