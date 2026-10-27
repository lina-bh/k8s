# AGENTS.md

## Quadlets

* All quadlets under `system_files/etc/containers/systemd/` are candidates to
  be migrated to Kubernetes (`k8s/apps/`) at some point.

## Attribution

* Each comment an agent writes or substantially rewrites SHOULD end with an
  attribution line of the form `Assisted-by: HARNESS:MODEL`, in the file's own
  comment syntax:

  ```yaml
  # Drop duplicated kubelet metrics.
  # Assisted-by: Claude Code:claude-opus-5-5
  ```

* `HARNESS` is the agent program (for example `Claude Code`, `Codex CLI`,
  `pi`), not the vendor. `MODEL` is the exact model identifier the harness
  reports (for example `claude-opus-5-5`), not a marketing name.
* If either part cannot be determined, MUST write `unknown` in its place
  rather than guess.
* The format is adapted from the Linux kernel's
  `Assisted-by: AGENT_NAME:MODEL_VERSION` commit trailer.
* This applies to comments only. Commit attribution is left to the agent's
  configuration.
