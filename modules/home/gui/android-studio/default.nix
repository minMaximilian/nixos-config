{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.myOptions.android-studio;

  # Fetch IdeaVim plugin directly from JetBrains Marketplace
  ideavimPlugin = pkgs.fetchzip {
    url = "https://plugins.jetbrains.com/plugin/download?rel=true&updateId=835262";
    hash = "sha256-pzsEVhIizKJEb9ruW9/o3AfQU4WlybJl8IXeJqBqdiM=";
    stripRoot = false;
    extension = "zip";
  };
in {
  options.myOptions.android-studio = {
    enable = mkEnableOption "Android Studio for KMP development";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.android-studio
      pkgs.jetbrains.idea
    ];

    # Install IdeaVim plugin to Android Studio's plugin directory
    home.file.".config/Google/AndroidStudio2025.2.3/plugins/IdeaVIM".source = "${ideavimPlugin}/IdeaVIM";

    # Install IdeaVim plugin to IntelliJ IDEA's plugin directory
    home.file.".config/JetBrains/IntelliJIdea2025.3/plugins/IdeaVIM".source = "${ideavimPlugin}/IdeaVIM";

    home.file.".ideavimrc".text = ''
      " IdeaVim configuration for Android Studio

      " Use system clipboard
      set clipboard+=unnamedplus

      " Smart join (IDE-aware)
      set ideajoin

      " Show mode in status bar
      set showmode

      " Incremental search
      set incsearch
      set hlsearch
      set ignorecase
      set smartcase

      " Line numbers
      set number
      set relativenumber

      " Scroll offset
      set scrolloff=8

      " Leader key
      let mapleader = " "

      " IDE action mappings
      nnoremap <leader>ff :action GotoFile<CR>
      nnoremap <leader>fg :action FindInPath<CR>
      nnoremap <leader>fr :action RecentFiles<CR>
      nnoremap <leader>e :action ActivateProjectToolWindow<CR>

      " Code navigation
      nnoremap gd :action GotoDeclaration<CR>
      nnoremap gi :action GotoImplementation<CR>
      nnoremap gr :action FindUsages<CR>
      nnoremap gy :action GotoTypeDeclaration<CR>
      nnoremap K :action QuickJavaDoc<CR>

      " Code actions
      nnoremap <leader>ca :action ShowIntentionActions<CR>
      nnoremap <leader>cr :action RenameElement<CR>
      nnoremap <leader>cf :action ReformatCode<CR>
      nnoremap <leader>co :action OptimizeImports<CR>

      " Run/Debug
      nnoremap <leader>rr :action Run<CR>
      nnoremap <leader>rd :action Debug<CR>
      nnoremap <leader>rs :action Stop<CR>

      " Window navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Tab navigation
      nnoremap <S-h> :action PreviousTab<CR>
      nnoremap <S-l> :action NextTab<CR>
      nnoremap <leader>bd :action CloseContent<CR>

      " Git
      nnoremap <leader>gb :action Git.Branches<CR>
      nnoremap <leader>gc :action CheckinProject<CR>
      nnoremap <leader>gp :action Git.Pull<CR>

      " Enable IdeaVim plugins
      set surround
      set commentary
      set argtextobj
      set highlightedyank
      set nerdtree
      set which-key
      set notimeout
    '';
  };
}
