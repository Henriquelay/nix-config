{
  config,
  pkgs,
  customXkbConfig,
  ...
}:
{
  imports = [
    ./stylix.nix
    ./programs.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "henriquelay";
    homeDirectory = "/home/henriquelay";
    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.05"; # Please read the comment before changing.
    sessionVariables = {
      TZ = "America/Sao_Paulo";
      # Hint electron apps to use Wayland
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      # Disable window decorator on QT applications
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    file = {
      ".claude/CLAUDE.md".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/hosts/acad-router/henriquelay/CLAUDE.md";

      ".XCompose".text =
        # xor
        ''
          include "%S/pt_BR.UTF-8/Compose"

          <Multi_key> <l> <l>             : "ℓ"   U2113  # litre symbol
          <Multi_key> <p> <i>             : "π"   U03C0  # GREEK SMALL LETTER PI
          <Multi_key> <i> <n> <f>	     	: "∞"   U221E  # infinite symbol
          <Multi_key> <s> <q> <r>	<t>     : "√"   U221A  # square root
          <Multi_key> <space> <space>	: "­"	U0173 	# Invisible valid space

          <Multi_key> <b> <t> <c>		: "₿"	U20BF	# Bitcoin symbol
          <Multi_key> <x> <m> <r>		: "ɱ"	U0271	# Monero symbol
          <Multi_key> <s> <s> <s>		: "≡"	# Se só se
          <Multi_key> <E> <E>		: "∃"	# Quantificador existencial
          <Multi_key> <A> <A>		: "∀"	# Quantificador universal
          <Multi_key> <e>	<e>		: "∧"	# Conjunção lógica
          <Multi_key> <o> <u>   : "∨"	# Disjunção lógica


          # http://newton.cx/~peter/2013/04/typing-greek-letters-easily-on-linux/
          # https://gist.github.com/pkgw/5422749
          # Greek ambiguities: epsilon/eta, theta/tau, pi/phi/psi, omega/omicron
          <Multi_key> <g> <a> : "α"
          <Multi_key> <g> <b> : "β"
          <Multi_key> <g> <g> : "γ"
          <Multi_key> <g> <d> : "δ"
          <Multi_key> <g> <e> : "ε"
          <Multi_key> <g> <z> : "ζ"
          <Multi_key> <g> <h> : "η" # note!
          <Multi_key> <g> <8> : "θ" # note!
          <Multi_key> <g> <i> : "ι"
          <Multi_key> <g> <k> : "κ"
          <Multi_key> <g> <l> : "λ"
          <Multi_key> <g> <m> : "μ"
          <Multi_key> <g> <n> : "ν"
          <Multi_key> <g> <x> : "ξ"
          <Multi_key> <g> <o> : "ο"
          <Multi_key> <g> <p> : "π"
          <Multi_key> <g> <r> : "ρ"
          <Multi_key> <g> <5> : "ς"
          <Multi_key> <g> <s> : "σ"
          <Multi_key> <g> <t> : "τ"
          <Multi_key> <g> <y> : "υ"
          <Multi_key> <g> <f> : "φ" # note!
          <Multi_key> <g> <c> : "χ"
          <Multi_key> <g> <u> : "ψ"
          <Multi_key> <g> <w> : "ω"
          # Greek alphabet
          <Multi_key> <G> <A> : "Α"
          <Multi_key> <G> <B> : "Β"
          <Multi_key> <G> <G> : "Γ"
          <Multi_key> <G> <D> : "Δ"
          <Multi_key> <G> <E> : "Ε"
          <Multi_key> <G> <Z> : "Ζ"
          <Multi_key> <G> <H> : "Η"
          <Multi_key> <G> <8> : "Θ"
          <Multi_key> <G> <I> : "Ι"
          <Multi_key> <G> <K> : "Κ"
          <Multi_key> <G> <L> : "Λ"
          <Multi_key> <G> <M> : "Μ"
          <Multi_key> <G> <N> : "Ν"
          <Multi_key> <G> <X> : "Ξ"
          <Multi_key> <G> <O> : "Ο"
          <Multi_key> <G> <P> : "Π"
          <Multi_key> <G> <R> : "Ρ"
          <Multi_key> <G> <S> : "Σ"
          <Multi_key> <G> <T> : "Τ"
          <Multi_key> <G> <Y> : "Υ"
          <Multi_key> <G> <U> : "Ψ"
          <Multi_key> <G> <F> : "Φ"
          <Multi_key> <G> <C> : "Χ"
          <Multi_key> <G> <W> : "Ω"
        '';
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.gruvbox-dark-icons-gtk;
      name = "gruvbox-dark-gtk";
    };
  };

  xdg.desktopEntries = {
    virt-manager = {
      # Fix for virt-manager on wlr
      name = "Virtual Machine Manager";
      exec = "virt-manager";
      terminal = false;
      categories = [
        "Utility"
        "Emulator"
      ];
    };
  };
}
