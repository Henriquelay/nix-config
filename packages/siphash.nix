{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "siphash";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "veorq";
    repo = "SipHash";
    rev = "refs/tags/${version}";
    hash = "sha256-kjn9T2ulklesV6zn0+z3J4ps/zWIwmfuC3Y3HKOv4FU=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    mv debug $out/debug
    mv test $out/test
    mv vectors $out/vectors

    runHook postInstall
  '';

  meta = {
    description = "High-speed secure pseudorandom function for short messages";
    homepage = "https://github.com/veorq/SipHash/";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ henriquelay ];
    platforms = [ "x86_64-linux" ];
  };
}
