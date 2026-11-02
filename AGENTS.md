# Repository Agent Rules

## 🔒 Scope & File Modification Restrictions

### 1. Primary Constraint (Batasan Utama)
You are **STRICTLY FORBIDDEN** from modifying any code, file, or configuration in this repository, **EXCEPT**:
- `hosts/default/configuration.nix` (`/home/fadlan/niks/hosts/default/configuration.nix`)

### 2. Allowed Actions (Aksi yang Diizinkan)
- You may freely read and inspect any files in the repository for context and analysis.
- You may directly edit and modify `hosts/default/configuration.nix` to fulfill user requests.

### 3. Prohibited Without Explicit Permission (Dilarang Mengubah File Lain Tanpa Izin)
- You must **NEVER** edit, modify, overwrite, delete, rename, or create any file other than `hosts/default/configuration.nix` without prior explicit permission from the user.
- This restriction applies to all files, including but not limited to:
  - `flake.nix` and `flake.lock`
  - All files under `hosts/` (except `hosts/default/configuration.nix`)
  - All files under `modules/` (e.g., `modules/system/*`, `modules/home/*`)
  - Any dotfiles, scripts, or root files
- **DO NOT** use file-editing tools (`replace_file_content`, `multi_replace_file_content`, `write_to_file`) on any file other than `hosts/default/configuration.nix` without explicit prior consent.
- **DO NOT** execute bash commands (e.g., `sed`, redirection `>`, `tee`, `patch`, `git restore`, `git checkout`, etc.) that alter any other file.

### 4. Mandatory Permission Protocol (Wajib Minta Izin)
If any task requires or would benefit from modifying a file other than `hosts/default/configuration.nix`:
1. **STOP**: Do NOT execute any edit or write operation on that file.
2. **EXPLAIN**: Inform the user clearly:
   - Which file needs to be modified.
   - Why the change is necessary.
   - A diff or exact preview of the proposed changes.
3. **ASK FOR PERMISSION**: Explicitly ask the user for permission to modify that specific file.
4. **WAIT**: Proceed with the modification **ONLY** after the user has explicitly granted permission in their reply.

---

## 🚫 Execution & Repository Rules

### 5. No System Build or Switch Commands (Dilarang Melakukan Build / Switch Sistem)
- You must **NEVER** execute system build, test, boot, or switch commands.
- **Strictly Prohibited Commands**:
  - `nh os switch`, `nh os test`, `nh os boot`, `nh home switch`
  - `nixos-rebuild switch`, `nixos-rebuild test`, `nixos-rebuild boot`, `nixos-rebuild build`
  - `nix build`, `nix run`, `nix profile`
  - Any command that applies changes or rebuilds the NixOS system generation.
- **Allowed**: Passive dry syntax evaluations only (e.g. `nix eval`, `nix flake check --no-build`).
- Always provide the build command as text instructions so the user can execute it manually in their terminal.

### 6. No Git / Repository Mutating Operations (Dilarang Mengubah State Repositori Git)
- You must **NEVER** perform Git commands that mutate repository history, branch state, or push changes.
- **Strictly Prohibited Commands**:
  - `git commit`
  - `git push`
  - `git merge`, `git rebase`
  - `git reset`, `git restore`, `git checkout`
  - `git branch -d` / `git branch -D`
  - `git stash pop` / `git stash drop`
- **Allowed**: Read-only Git inspection commands only (e.g. `git status`, `git diff`, `git log`, `git branch --list`).
- Any commit, push, or Git state modification must be done exclusively by the user.
