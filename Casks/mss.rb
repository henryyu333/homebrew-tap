cask "mss" do
  version "0.1.0"

  on_macos do
    on_arm do
      sha256 "841d1de70d1553732c78441bfefd343c9b12a56351acb8c49131dbac826a2526"
      url "https://github.com/henryyu333/mss/releases/download/v#{version}/mss_#{version}_darwin_arm64.tar.gz"
    end
    on_intel do
      sha256 "e6702d41db21bdc0165aa3036ac990a1bdd6076cbcdd1af639dc29b72b51ea03"
      url "https://github.com/henryyu333/mss/releases/download/v#{version}/mss_#{version}_darwin_amd64.tar.gz"
    end
  end
  on_linux do
    on_arm do
      sha256 "6a129ed5e9633ce3d1ce3f484160e449bdbe0b6759107c93db138160662d10b4"
      url "https://github.com/henryyu333/mss/releases/download/v#{version}/mss_#{version}_linux_arm64.tar.gz"
    end
    on_intel do
      sha256 "6b1a796327ecc2a3d8c66d9c3db42a3e1a3bc593a1a74a5a10cb3f28aafb0aac"
      url "https://github.com/henryyu333/mss/releases/download/v#{version}/mss_#{version}_linux_amd64.tar.gz"
    end
  end

  name "mss"
  desc "Search your AI coding history. On demand."
  homepage "https://github.com/henryyu333/mss"

  livecheck do
    skip "Auto-generated on release."
  end
  depends_on formula: [
      "zstd",
    ]

  binary "mss"

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/mss"]
    end
  end

  # No zap stanza required
end
