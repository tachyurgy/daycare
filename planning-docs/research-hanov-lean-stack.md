# Research: Steve Hanov's $20/mo Lean Stack

Source: https://stevehanov.ca/blog/how-i-run-multiple-10k-mrr-companies-on-a-20month-tech-stack
HN: https://news.ycombinator.com/item?id=47736555
Captured: 2026-04-17

---

## Blog: Hanov's Stack

### Server & Hosting
- **VPS Provider**: Linode or DigitalOcean
- **Cost**: $5–10/month
- **Specs**: 1GB RAM (uses swapfile for additional capacity)
- **Deployment**: Compile Go binary locally, `scp` to server, run directly

### Backend Language — Go
Chosen for:
- Performance on constrained hardware
- Single statically-linked binary compilation
- No dependency management overhead
- "Incredibly easy for LLMs to reason about"

Minimal production example:
```go
package main
import ("fmt"; "net/http")
func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello, your MRR is safe here.")
    })
    http.ListenAndServe(":8080", nil)
}
```

### Database — SQLite with WAL
```
PRAGMA journal_mode=WAL;
PRAGMA synchronous=NORMAL;
```
Claim: "thousands of concurrent users" per single `.db` file on NVMe.

### AI/GPU Infrastructure
- **Local inference**: VLLM on RTX 3090 (24GB VRAM, ~$900 used)
- **Iteration tool**: Ollama (`ollama run qwen3:32b`)
- **Custom tools**: laconic (context mgmt), llmhub (multi-provider abstraction)
- **Cloud fallback**: OpenRouter for frontier models with automatic failover

### Dev Tools
- VS Code + GitHub Copilot (~$60/mo total)
- "Microsoft charges per request, not per token"

### Auth
Custom `smhanov/auth` lib — Google, Facebook, X, SAML without "bloated dependencies".

### Total Monthly Cost
~$20/mo for running multiple $10K MRR companies.

---

## HN Discussion — Key Counterpoints

### Critiques
- **Postgres-vs-SQLite speed claim overstated**: Postgres over Unix sockets closes the gap significantly; SQLite still wins on trivial queries like `SELECT 1`.
- **Scaling limits**: Multi-region traffic forces either state-sync or sharding; single droplet doesn't serve global latency.
- **Write concurrency**: SQLite's single-writer default has "no tolerance for concurrent writes" without per-connection `busy_timeout`.

### Backup & Durability
- **Litestream** was the consensus recommendation — streaming replication to S3, sub-second RPO.
  - Caveat: small window where confirmed writes may be lost before replication completes.
- Alternatives: rsync + cron to rsync.net, Restic snapshots, VPS-provider backups.

### Failure Modes Noted
1. **Schema evolution** on huge tables — SQLite lacks Postgres's non-blocking DDL.
2. **Multi-region writes** — impractical; region-sharding required.
3. **Operational skill gaps** — engineers trained only on Kubernetes sometimes lack basic VPS admin skills.

### Points of Agreement
- For sub-1000-user products or $10K MRR businesses, a single droplet with SQLite is pragmatic.
- Premature scaling (cargo-cult K8s) is real; SQLite→Postgres migration is tractable if needed later.

### When the Stack Breaks
- Geographic read-heavy workloads
- Multiple concurrent writers across regions
- Strict durability requirements without external replication tooling
