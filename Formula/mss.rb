# Generated from the exact tagged source; publish to the external tap separately.
class Mss < Formula
  desc "Recall and summarize past AI coding sessions, no memory system needed"
  homepage "https://github.com/henryyu333/mss"
  url "https://github.com/henryyu333/mss/releases/download/v0.3.0/mss_0.3.0_source.tar.gz"
  sha256 "0f5a2b2b624d93d3efced289a9b0a2892af97eeaf579badc40703175040c8a78"
  license "MIT"

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=0.3.0"), "./cmd/mss"
    pkgshare.install "skills/mss"
  end

  def caveats
    <<~EOS
      Install the skill explicitly: mss install-skill <claude|codex|pi|omp>
      sqlite3 and zstd are optional runtime tools for SQLite/compressed stores.
      No hooks, agent settings, or existing skills are changed automatically.
    EOS
  end

  test do
    assert_equal "mss 0.3.0", shell_output("#{bin}/mss version").strip
    ENV["HOME"] = testpath.to_s
    system bin/"mss", "install-skill", "codex"
    assert_equal (pkgshare/"mss/SKILL.md").read, (testpath/".agents/skills/mss/SKILL.md").read
    assert_equal (pkgshare/"mss/agents/openai.yaml").read,
                 (testpath/".agents/skills/mss/agents/openai.yaml").read
  end
end
