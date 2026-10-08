class Mss < Formula
  desc "Search your AI coding history on demand"
  homepage "https://github.com/henryyu333/mss"
  url "https://github.com/henryyu333/mss/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "df007cd20e279fe675ff603ac588d9476b44847fc28d19e6968e398053d657cb"
  license "MIT"

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: "-X main.version=#{version}"), "./cmd/mss"
  end

  def caveats
    <<~EOS
      Optional runtime tools are discovered on PATH at run time, not
      dependencies: the sqlite3 CLI reads SQLite-backed stores (opencode,
      Cursor IDE, Grok — macOS ships /usr/bin/sqlite3) and the zstd CLI reads
      zstd-compressed transcripts (newer Codex rollouts, DeepSeek Harness —
      `brew install zstd`). Without them mss still runs; `mss doctor` names
      the stores it could not read.

      The agent skill is not installed for you (v0.2.0 has no installer):
      copy skills/mss/SKILL.md from the source tree into your agent's skills
      directory per the upstream README.
    EOS
  end

  test do
    assert_equal "mss #{version}", shell_output("#{bin}/mss version").strip

    # Exercise retrieval from synthetic history without reading the user's stores.
    (testpath/"home").mkpath
    ENV["HOME"] = (testpath/"home").to_s
    ENV["XDG_CONFIG_HOME"] = (testpath/"config").to_s
    ENV["MSS_STORES"] = "claude"
    ENV["MSS_CLAUDE_ROOT"] = (testpath/"store").to_s
    ENV["MSS_INDEX_DIR"] = (testpath/"index").to_s
    (testpath/"store/test-project").mkpath
    (testpath/"store/test-project/session-1.jsonl").write <<~EOS
      {"type":"user","sessionId":"brew-smoke-session","timestamp":"2026-10-01T12:00:00Z","uuid":"u1","cwd":"/test-project","version":"0.2.0","message":{"role":"user","content":"brew smoke needle message"}}
      {"type":"assistant","sessionId":"brew-smoke-session","timestamp":"2026-10-01T12:00:05Z","uuid":"a1","cwd":"/test-project","version":"0.2.0","message":{"role":"assistant","content":[{"type":"text","text":"brew smoke reply"}]}}
    EOS

    system bin/"mss", "index"
    result = JSON.parse(shell_output("#{bin}/mss search --no-refresh --json 'brew smoke needle'"))
    assert_equal "exact", result["tier"]
    assert_equal ["brew-smoke-session"], result["hits"].map { |hit| hit.dig("session", "id") }
  end
end
