---
id: pun-07b1
status: blocked
deps: []
created: 2026-02-26T17:18:51Z
type: task
priority: 2
---
# Let's make the hold bar action on blocked ticket behave differently: if there are no open questions, it should _open_ the ticket (assumption is it failed or we held on it, now we're ready to make it actionable again). If there _are_ open questions, then hold should still close the ticket (if we wanted to make it actionable, we could have answered the questions)

## Notes

**2026-02-26 17:29:11 UTC:** ko: FAIL at node 'verify' — node 'verify' failed after 3 attempts: command failed: exit status 1
error:
       … while calling the 'import' builtin
         at «string»:1:18:
            1| {...}@args: with import <nixpkgs> args; (pkgs.runCommandCC or pkgs.runCommand) "shell" { buildInputs = [ (sshpass) (rsync) ]; } ""
             |                  ^

       … while realising the context of a path

       … while calling the 'findFile' builtin
         at «string»:1:25:
            1| {...}@args: with import <nixpkgs> args; (pkgs.runCommandCC or pkgs.runCommand) "shell" { buildInputs = [ (sshpass) (rsync) ]; } ""
             |                         ^

       error: file 'nixpkgs' was not found in the Nix search path (add it using $NIX_PATH or -I)
error: Recipe `sync` failed with exit code 1

