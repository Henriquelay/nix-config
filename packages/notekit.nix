{
  stdenv,
  fetchFromGitHub,
  meson,
  cmake,
  ninja,
  pkg-config,
  gtkmm3,
  jsoncpp,
  gtksourceview,
  gtksourceviewmm,
  fontconfig,
  zlib,
  tinyxml-2,
  gsettings-desktop-schemas,
  wrapGAppsHook3,
}:
stdenv.mkDerivation {
  pname = "notekit";
  version = "v0.2.0";

  src = fetchFromGitHub {
    owner = "blackhole89";
    repo = "notekit";
    rev = "v0.2.0";
    sha256 = "0p9ijfxzr2lcc9h1fsqjhmyqkwyl1si69ax5x46c2sqlbx53azyi";
  };

  configurePhase = ''
    runHook preConfigure
    chmod +x install-clatexmath.sh
    ./install-clatexmath.sh
    meson _build
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    ninja -C _build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    meson install -C _build --destdir $out
    mv $out/usr/local/bin $out
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : $out/usr/local/share
    )
  '';

  # Build dependencies
  nativeBuildInputs = [
    meson
    gtkmm3
    jsoncpp
    gtksourceview
    gtksourceviewmm
    fontconfig
    zlib
    cmake
    ninja
    pkg-config
    tinyxml-2
    wrapGAppsHook3
  ];

  # Runtime dependencies
  buildInputs = [
    gtkmm3
    jsoncpp
    zlib
    tinyxml-2
    gtksourceview
    gtksourceviewmm
    # glib
    # gtk3
    gsettings-desktop-schemas
  ];
}
