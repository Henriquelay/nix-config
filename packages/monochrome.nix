{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchzip,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  makeDesktopItem,
  copyDesktopItems,
  gtk3,
  glib,
  gdk-pixbuf,
  cairo,
  webkitgtk_4_1,
  libsoup_3,
  libayatana-appindicator,
  gst_all_1,
  python3,
}:

let
  neutralino-bin = fetchzip {
    url = "https://github.com/neutralinojs/neutralinojs/releases/download/v6.5.0/neutralinojs-v6.5.0.zip";
    hash = "sha256-GiZ8CMh4vUcJFZVKijg7E7/+1UHyM0n0gO4BP8OCwFE=";
    stripRoot = false;
  };

  firebase-version = "10.7.1";

  firebase-app-js = fetchurl {
    url = "https://www.gstatic.com/firebasejs/${firebase-version}/firebase-app.js";
    hash = "sha256-orU6npELCZl//Ihmu+vMbokj0/tFSNg/o2La6jXv4Vc=";
  };
  firebase-auth-js = fetchurl {
    url = "https://www.gstatic.com/firebasejs/${firebase-version}/firebase-auth.js";
    hash = "sha256-QdQmGHvt+WGVQYr8tb5FIBhgkZCOeaQNYyyPl+zD0g4=";
  };
  firebase-database-js = fetchurl {
    url = "https://www.gstatic.com/firebasejs/${firebase-version}/firebase-database.js";
    hash = "sha256-1H+FRE4HH2VQ4f0nZo5ndswLylF/A0ujiY/5Bq1i8GM=";
  };
in
buildNpmPackage {
  pname = "monochrome";
  version = "0-unstable-2026-02-11";

  src = fetchFromGitHub {
    owner = "monochrome-music";
    repo = "monochrome";
    rev = "3a1e3baec20e2f08196adaf7357b33586078b008";
    hash = "sha256-enZVe1qzOWzRzWhPi5YXZ1LLYpQeGzuILzILbkLikpI=";
  };

  npmDepsHash = "sha256-J0MpoyFs4wNBhcxIEXf75nKpQW/FWRINwbVN6/1F1VY=";

  # WebKit2GTK compatibility patches (applied before build):
  # - Split build so we can patch JS between vite and neu steps
  # - Disable modulePreload (its polyfill sets crossOrigin on <link> elements)
  # - Default to dark theme (system theme detection is unreliable in WebKit2GTK)
  # - Fix cross-origin iframe (127.0.0.1 parent vs localhost iframe)
  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "vite build --mode neutralino && bun x neu build" "vite build --mode neutralino"

    substituteInPlace vite.config.js \
      --replace-fail "outDir: 'dist'," "outDir: 'dist', modulePreload: false,"

    substituteInPlace index.html \
      --replace-fail '<html lang="en">' '<html lang="en" data-theme="monochrome">' \
      --replace-fail '</head>' '<script>if(!localStorage.getItem("monochrome-theme"))localStorage.setItem("monochrome-theme","monochrome")</script></head>'

    substituteInPlace public/neutralino_loader.html \
      --replace-fail 'http://localhost:''${port}' 'http://127.0.0.1:''${port}'
  '';

  makeCacheWritable = true;

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    gtk3
    glib
    gdk-pixbuf
    cairo
    webkitgtk_4_1
    libsoup_3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
  ];

  # Place Neutralino binary where `neu build` expects it
  preBuild = ''
    mkdir -p bin
    cp ${neutralino-bin}/neutralino-linux_x64 bin/
    chmod +x bin/neutralino-linux_x64
  '';

  # After vite build, patch the output for WebKit2GTK compatibility,
  # then run neu build to package everything into resources.neu.
  #
  # WebKit2GTK silently fails to load ES modules from external CDN URLs
  # and rejects crossorigin attributes on localhost resources. We bundle
  # Firebase ESM files locally and rewrite all import paths.
  postBuild = ''
    # Bundle Firebase ESM files locally and patch their internal CDN imports
    mkdir -p dist/assets/firebase
    cp ${firebase-app-js} dist/assets/firebase/firebase-app.js
    cp ${firebase-auth-js} dist/assets/firebase/firebase-auth.js
    cp ${firebase-database-js} dist/assets/firebase/firebase-database.js
    chmod +w dist/assets/firebase/*.js

    substituteInPlace dist/assets/firebase/firebase-auth.js \
      --replace-fail "https://www.gstatic.com/firebasejs/${firebase-version}/firebase-app.js" "./firebase-app.js"
    substituteInPlace dist/assets/firebase/firebase-database.js \
      --replace-fail "https://www.gstatic.com/firebasejs/${firebase-version}/firebase-app.js" "./firebase-app.js"

    # Strip crossorigin attributes from HTML
    substituteInPlace dist/index.html \
      --replace-fail 'type="module" crossorigin src=' 'type="module" src=' \
      --replace-fail 'crossorigin href=' 'href='

    # Rewrite Firebase CDN imports in all JS chunks (main bundle + code-split)
    for jsfile in dist/assets/*.js; do
      substituteInPlace "$jsfile" \
        --replace-warn "https://www.gstatic.com/firebasejs/${firebase-version}/firebase-app.js" "./firebase/firebase-app.js" \
        --replace-warn "https://www.gstatic.com/firebasejs/${firebase-version}/firebase-auth.js" "./firebase/firebase-auth.js" \
        --replace-warn "https://www.gstatic.com/firebasejs/${firebase-version}/firebase-database.js" "./firebase/firebase-database.js"
    done

    # Replace VitePWA service worker with a no-op (precache checksums
    # are stale after patching and SW is unnecessary for a desktop app)
    echo "self.addEventListener('install',()=>self.skipWaiting());self.addEventListener('activate',e=>e.waitUntil(self.clients.claim()));" > dist/sw.js
    rm -f dist/workbox-*.js

    npx @neutralinojs/neu build
  '';

  dontNpmInstall = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/monochrome
    cp dist/Monochrome/Monochrome-linux_x64 $out/share/monochrome/Monochrome
    cp dist/Monochrome/resources.neu $out/share/monochrome/
    cp -r dist/Monochrome/extensions $out/share/monochrome/ || true

    mkdir -p $out/share/icons/hicolor/512x512/apps
    mkdir -p $out/share/icons/hicolor/scalable/apps
    cp public/assets/512.png $out/share/icons/hicolor/512x512/apps/monochrome.png
    cp public/assets/logo.svg $out/share/icons/hicolor/scalable/apps/monochrome.svg

    mkdir -p $out/bin

    runHook postInstall
  '';

  dontWrapGApps = true;

  # Neutralino resolves its base path from /proc/self/exe, so the binary
  # must live in a writable directory for .tmp/ and log file creation.
  # We copy the binary and symlink resources into a per-user state dir.
  postFixup = ''
    makeWrapper $out/share/monochrome/Monochrome $out/bin/monochrome \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ webkitgtk_4_1 libsoup_3 libayatana-appindicator ]}" \
      --prefix PATH : "${lib.makeBinPath [ python3 ]}" \
      --run 'MONOCHROME_STATE_DIR="''${XDG_STATE_HOME:-$HOME/.local/state}/monochrome"' \
      --run 'mkdir -p "$MONOCHROME_STATE_DIR"' \
      --run 'for f in resources.neu extensions; do [ ! -e "$MONOCHROME_STATE_DIR/$f" ] && ln -sf "'"$out"'/share/monochrome/$f" "$MONOCHROME_STATE_DIR/$f"; done' \
      --run 'if [ ! -x "$MONOCHROME_STATE_DIR/Monochrome" ] || [ "'"$out"'/share/monochrome/Monochrome" -nt "$MONOCHROME_STATE_DIR/Monochrome" ]; then cp -f "'"$out"'/share/monochrome/Monochrome" "$MONOCHROME_STATE_DIR/Monochrome"; fi' \
      --run 'exec "$MONOCHROME_STATE_DIR/Monochrome" "$@"'
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "monochrome";
      desktopName = "Monochrome";
      comment = "Minimalist, unlimited music streaming";
      exec = "monochrome";
      icon = "monochrome";
      categories = [
        "Audio"
        "Music"
        "Player"
      ];
    })
  ];

  meta = {
    description = "Minimalist, unlimited music streaming desktop application";
    homepage = "https://github.com/monochrome-music/monochrome";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "monochrome";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
}
