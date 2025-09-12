{
  lib,
  rustPlatform,
  fetchFromSourcehut,
  pkg-config,
# Add any additional dependencies here
# For example: openssl, sqlite, etc.
}:

rustPlatform.buildRustPackage rec {
  pname = "mediaarchivistbot";
  version = "0.0.3";

  src = fetchFromSourcehut {
    owner = "~damnorangecat";
    repo = "media-archivist-bot";
    rev = "c67e3895aa0859067fed734762bf79c1e2c407db";
    hash = "sha256-AjvuW9voJRjkXgJdl4Z2xay+g1wxyDwrWfpjHRTVA6w=";
  };

  cargoHash = "sha256-AcfDTyGHxvZlQn0nngsj31aLxG+r7eeUVSkLoUW+O2A=";

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
    description = "A simple telegram bot that downloads media in a chat and sends it.";
    homepage = "https://git.sr.ht/~damnorangecat/media-archivist-bot";
    license = licenses.unlicense;
    maintainers = with maintainers; [ henriquelay ];
    platforms = platforms.linux;
    mainProgram = "mediaarchivistbot";
  };
}
