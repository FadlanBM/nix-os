{
  programs.git = {
    enable = true;
    lfs.enable = true;
    # signing.format = "openpgp";
    settings = {
      user = {
        name = "FadlanBM";
        email = "";
        signingkey = "";
      };
      alias = {
        pu = "push";
        co = "checkout";
        ci = "commit -v";
        cm = "commit -m";
        br = "branch";
        st = "status";
        di = "diff";
      };
      pull = {
        rebase = false;
      };
      commit = {
        gpgsign = false;
      };
    };
  };
}
