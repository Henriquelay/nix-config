{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
}:

stdenv.mkDerivation rec {
  pname = "fae_linux";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "UnlegitSenpaii";
    repo = "FAE_Linux";
    rev = "refs/tags/v${version}";
    # hash = "sha256-0jgs33k8h46nswjh5fb5x6x2kc67db5qap5zbrw78nclbxiqf386";
    hash = "sha256-NfK2XkgEIMpIIxlFftH/0dFQ7e8+d1gLYb1d1NeMTP8=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 out/bin/FAE_Linux $out/bin/fae_linux    

    runHook postInstall
  '';

  meta = {
    description = "Factorio Achievement Enabler for Linux";
    homepage = "https://github.com/UnlegitSenpaii/FAE_Linux";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ henriquelay ];
    platforms = [ "x86_64-linux" ];
  };
}
