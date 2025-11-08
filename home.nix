{ config, pkgs, username, homeDirectory, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.pure-prompt
    pkgs.ripgrep
    pkgs.fd
    pkgs.eza
    pkgs.zoxide
    pkgs.uv
    pkgs.ruff
    pkgs.docker
    pkgs.ghq
    pkgs.asterisk_22
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/furon/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "furon-kuina";
    userEmail = "tenma.edamura@gmail.com";
    aliases = {
      s = "status";
      a = "add";
      c = "commit";
      sw = "switch";
      co = "checkout";
      cb = "switch -c";
      l = "log";
      ll = "log --oneline";
    };
    extraConfig = {
      init.defaultBranch = "main";
      branch.sort = "committerdate";
      tag.sort = "version:refname";
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      pull.rebase = true;
      fetch = {
        prune = true; 
        pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      commit.verbose = true;
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      ghq.root = "~/Development/repo";
    };
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;
    # TODO: define initContent by concatenating configs for each packages
    initContent = ''
    autoload -U promptinit; promptinit
    zstyle ':prompt:pure:prompt:error' color 205
    zstyle ':prompt:pure:prompt:success' color 086
    prompt pure
    export LOCALE_ARCHIVE="$(nix profile list | grep glibcLocales | tail -n1 | cut -d ' ' -f4)/lib/locale/locale-archive"
    export PATH="/home/furon/.local/bin:$PATH"
    alias tf="terraform"
    alias fzc="git branch --list | cut -c 3- | fzf --preview \"git log --pretty=format:'%h %cd %s' --date=format:'%Y-%m-%d %H:%M' {}\" | xargs git checkout"

    switch_branch_fzf() {
      local branch
      # Use git for-each-ref for a more robust way to get branch names
      branch=$(git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)' | fzf --preview "git log --pretty=format:'%h %cd %s' --date=format:'%Y-%m-%d %H:%M' {}")

      # Only proceed if a branch was selected
      if [[ -n "$branch" ]]; then
        BUFFER="git switch $branch"
        zle accept-line
      else
        # If no branch was selected, clear the command line
        BUFFER=""
        zle redisplay
      fi
    }
    zle -N switch_branch_fzf
    bindkey '^b' switch_branch_fzf

    switch_repo_fzf() {
      local src=$(ghq list | fzf --preview "ls -la $(ghq root)/{} | tail -n+4 | awk '{print \$9}'")
      if [ -n "$src" ]; then
        BUFFER="cd $(ghq root)/$src"
        zle accept-line
      fi
      zle -R -c
    }
    zle -N switch_repo_fzf
    bindkey '^]' switch_repo_fzf

    eval "$(zoxide init zsh)"
    eval "$(mise activate zsh)"
    '';
  };

  programs.gh = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.awscli = {
    enable = true;
  };

  programs.opam = {
    enable = true;
    enableZshIntegration = true;
  };

  # TODO: manage tailscale with Home Manager
}
