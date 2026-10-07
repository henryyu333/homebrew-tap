cask "mss" do
  version "0.2.0"

  on_macos do
    on_arm do
      sha256 "9b51589bb18f45bff40a3f6fd4442d43c15c0b64b1714d8f2719766d90e3c1e1"
      url "https://github.com/henryyu333/mss/releases/download/v#{version}/mss_#{version}_darwin_arm64.tar.gz"
    end
    on_intel do
      sha256 "8cec2054c4115d67a41f39f25742efc45ad59330af0885b2af19fa4628e17943"
      url "https://github.com/henryyu333/mss/releases/download/v#{version}/mss_#{version}_darwin_amd64.tar.gz"
    end
  end
  on_linux do
    on_arm do
      sha256 "f286d977da53a460fda1855d292270fa51400f97826ced0d77473ac229551576"
      url "https://github.com/henryyu333/mss/releases/download/v#{version}/mss_#{version}_linux_arm64.tar.gz"
    end
    on_intel do
      sha256 "bbe583d34a650213127a95b73827033f76776602681a05b9101a44f59e913bac"
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
