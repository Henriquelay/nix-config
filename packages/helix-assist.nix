{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "helix-assist";
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "leona";
    repo = "helix-assist";
    rev = "refs/tags/v${version}";
    hash = "sha256-XYbxEGATUiBLJamwrwmAR1UbyTg6A1QcmJyIxagl3g0=";
  };

  vendorHash = null;

  ldflags = [
    "-X main.Version=v${version}"
  ];

  subPackages = [ "cmd/helix-assist" ];

  meta = with lib; {
    description = "Code assistant language server for Helix with support for OpenAI/Anthropic";
    homepage = "https://github.com/leona/helix-assist";
    license = licenses.mit;
    maintainers = with maintainers; [ henriquelay ];
    platforms = platforms.linux;
    mainProgram = "helix-assist";
  };
}
