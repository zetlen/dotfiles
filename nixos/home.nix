# The Nix counterpart of install_dotfiles.sh: each block below names the
# installer step it stands in for.
{ lib, pkgs, dotfiles, ... }:
let
  skel = dotfiles + "/skel";
  gitconfigDir = dotfiles + "/lib/gitconfig";
  claudeFragments = dotfiles + "/lib/claude/settings";

  # Nix installs everything these would have mise install, so linking them
  # would only make mise download a second copy of each tool.
  skelExcludes = [
    ".config/mise/conf.d/10-langs.toml"
    ".config/mise/conf.d/20-utils.toml"
  ];

  skelRelPath = p: lib.removePrefix "${toString skel}/" (toString p);

  skelFiles = lib.filter (p: !lib.elem (skelRelPath p) skelExcludes) (
    lib.filesystem.listFilesRecursive skel
  );

  mergirafAttributes = pkgs.runCommand "mergiraf-gitattributes" { } ''
    ${lib.getExe pkgs.mergiraf} languages --gitattributes | sed '/^$/d' > $out
  '';

  # Every numbered fragment, plus tool.<cmd>.json for each <cmd> installed
  # below. worktrunk's command is `wt`.
  claudeSettingsFragments =
    lib.filter (p: builtins.match "[0-9].*\\.json" (baseNameOf p) != null) (
      lib.filesystem.listFilesRecursive claudeFragments
    )
    ++ [ (claudeFragments + "/tool.wt.json") ];

  # Same merge as merge_json_fragments in lib/installing.sh: Claude Code
  # rewrites settings.json in place, so it can't be a read-only store link.
  mergeClaudeSettings = pkgs.writeShellScript "merge-claude-settings" ''
    set -eu
    live="$HOME/.claude/settings.json"
    mkdir -p "$HOME/.claude"
    [ -s "$live" ] || echo '{}' > "$live"
    ${lib.getExe pkgs.jq} -s 'reduce .[] as $frag ({}; . * $frag)' \
      "$live" ${lib.escapeShellArgs claudeSettingsFragments} > "$live.tmp"
    mv "$live.tmp" "$live"
  '';
in
{
  home.stateVersion = "26.05";

  # 30 linking to homedir. The repo itself goes to ~/.dotfiles because the rc
  # files source lib/ from there at runtime. It's a read-only store copy:
  # edit the checkout on the host and rebuild.
  home.file =
    lib.listToAttrs (
      map (p: {
        name = skelRelPath p;
        value.source = p;
      }) skelFiles
    )
    // {
      ".dotfiles".source = dotfiles;

      # 50 installing bash extras
      ".bash-git-prompt".source = pkgs.bash-git-prompt;

      # lib/runtimes.sh only activates a mise at this exact path.
      ".local/bin/mise".source = lib.getExe pkgs.mise;
    };

  # 40 writing gitconfig. Written to the XDG location so ~/.gitconfig stays
  # free for tools that write to it, like `gh auth setup-git` and
  # `tea login helper setup` (see gitconfigWritable below). The include
  # list is what the installer would enable given the packages below;
  # libsecret, meld and ksdiff have no tool here. gpgsign comes after the
  # includes to override tools/gpg: the secret key isn't on this machine.
  xdg.configFile."git/config".text = ''
    [user]
    	name = zetlen
    	email = zetlen@gmail.com
    	signingkey = D4887C25BD67E87C
    [include]
    	path = ${gitconfigDir}/common.gitconfig
    	path = ${gitconfigDir}/tools/difft/.gitconfig
    	path = ${gitconfigDir}/tools/gpg/.gitconfig
    	path = ${gitconfigDir}/tools/mergiraf/.gitconfig
    	path = ${gitconfigDir}/tools/tea/.gitconfig
    [commit]
    	gpgsign = false
  '';
  xdg.configFile."git/attributes".source = mergirafAttributes;

  # `git config --global` writes to ~/.gitconfig only if it exists; failing
  # that, it picks the XDG file above, which is a read-only store link. An
  # empty ~/.gitconfig gives those writes a home. Git reads it after the XDG
  # file, so what tools put there wins.
  home.activation.gitconfigWritable = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -e "$HOME/.gitconfig" ] || run touch "$HOME/.gitconfig"
  '';

  # 90 writing claude settings
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${mergeClaudeSettings}
  '';

  # Linking gpg-agent.conf makes home-manager create ~/.gnupg as 0755, and
  # gnupg warns about unsafe permissions on every call until it's 0700.
  home.activation.gnupgPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run chmod 700 "$HOME/.gnupg"
  '';

  # 20 system packages, 60 tool versions (lib/mise conf.d), 80 editors
  # (lib/vim/30-editor.toml).
  home.packages = with pkgs; [
    # Debian/Arch install.sh basics
    gcc
    gnumake
    gnupg
    lsof
    unzip
    xz
    bc # fzf sizer in 55-helpers-zellij.zsh
    rsync # r / rr aliases

    # 10-langs.toml
    go
    nodejs
    python312

    # 20-utils.toml
    atuin
    bat
    bitwarden-cli
    bun
    cargo-binstall
    cmake
    delta
    difftastic
    dust
    eza
    fd
    fzf
    gh
    git-lfs
    glow
    hwatch
    jq
    mergiraf
    osc
    rexi
    ripgrep
    starship
    tree-sitter
    usage
    uv
    worktrunk
    yq-go
    zellij

    # 60 tool versions: rustup (run `rustup default stable` once)
    rustup

    # 30-editor.toml
    neovim
    gopls
    lua-language-server
    ruff
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server

    # Tools the skel/ configs and gitconfig includes are written for
    claude-code
    herdr
    opencode
    tea
  ];
}
