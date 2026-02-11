{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  # Add any additional dependencies here
  # For example: openssl, sqlite, etc.
}:

rustPlatform.buildRustPackage rec {
  pname = "linkredirbot";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "henriquelay";
    repo = "linkredirbot";
    rev = "aff34e08c39c0583f0332fadb63a2d627c51d3fc";
    hash = "sha256-OLe/mSofTtoJEzl0S2moIugZyM3hdVP3otSCa60Xcb8=";
  };

  cargoHash = "sha256-DNZZXW9VnyDS/JBKu0pXh/A8BrWS3EC6toYO/W1fQ84=";

  # Uncomment if you need additional build dependencies
  # nativeBuildInputs = [
  #   pkg-config
  # ];

  # Uncomment if you need runtime libraries
  # buildInputs = [
  #   openssl
  # ];

  # Uncomment if you need to set environment variables during build
  # OPENSSL_NO_VENDOR = 1;

  meta = with lib; {
    description = "A simple bot that replies to links with another better alternative for it";
    homepage = "https://github.com/Henriquelay/linkredirbot";
    license = licenses.unlicense;
    maintainers = with maintainers; [ henriquelay ];
    platforms = platforms.linux;
    mainProgram = "linkredirbot";
  };
}
