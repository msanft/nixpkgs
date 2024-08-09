{
  cmake,
  darwin,
  fetchFromGitHub,
  ffmpeg,
  fontconfig,
  git,
  lib,
  libGL,
  libxkbcommon,
  makeDesktopItem,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  wayland,
  wayland-scanner,
  libffi,
  libdrm,
  xorg,
}:

rustPlatform.buildRustPackage rec {
  pname = "gossip";
  version = "0.11.2";

  src = fetchFromGitHub {
    hash = "sha256-aw4ODQlg+/laDittt1gyHDR2wBkowyyj/qRH9jHO534=";
    owner = "mikedilger";
    repo = "gossip";
    rev = "refs/tags/v${version}";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "egui-video-0.1.0" = "sha256-X75gtYMfD/Ogepe0uEulzxAOY1YpkBW6OPhgovv/uCQ=";
      "gossip-relay-picker-0.2.0-unstable" = "sha256-zBxsuyXPOJuC5aMSc3+EbaV0zvDIT5QF5zNIe7Q9LvU=";
      "nip44-0.1.0" = "sha256-u2ALoHQrPVNoX0wjJmQ+BYRzIKsi0G5xPbYjgsNZZ7A=";
      "qrcode-0.12.0" = "sha256-onnoQuMf7faDa9wTGWo688xWbmujgE9RraBialyhyPw=";
      "ecolor-0.26.2" = "sha256-Ih1JbiuUZwK6rYWRSQcP1AJA8NesJJp+EeBtG0azlw0=";
      "ffmpeg-next-7.0.2" = "sha256-LVdaCbPHHEolcrXk9tPxUJiPNCma7qRl53TPKFijhFA=";
      "lightning-0.0.123-beta" = "sha256-gngH0mOC9USzwUGP4bjb1foZAvg6QHuzODv7LG49MsA=";
      "musig2-0.1.0" = "sha256-++1x7uHHR7KEhl8LF3VywooULiTzKeDu3e+0/c/8p9Y=";
      "nostr-types-0.8.0-unstable" = "sha256-47cL4TtUfMbA1h/j0McKrY4zJR2ZJF4i+LbTgc8wVAs=";
      "sdl2-0.36.0" = "sha256-dfXrD9LLBGeYyOLE3PruuGGBZ3WaPBfWlwBqP2pp+NY=";
    };
  };

  # See https://github.com/mikedilger/gossip/blob/0.9/README.md.
  RUSTFLAGS = "--cfg tokio_unstable";

  # Some users might want to add "rustls-tls(-native)" for Rust TLS instead of OpenSSL.
  buildFeatures = [
    "video-ffmpeg"
    "lang-cjk"
  ];

  nativeBuildInputs = [
    cmake
    git
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs =
    [
      ffmpeg
      fontconfig
      libGL
      libxkbcommon
      libffi
      libdrm
      openssl
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.CoreGraphics
      darwin.apple_sdk.frameworks.Foundation
    ]
    ++ lib.optionals stdenv.isLinux [
      wayland
      wayland-scanner
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
    ];

  # Tests rely on local files, so disable them. (I'm too lazy to patch it.)
  doCheck = false;

  postInstall = ''
    mkdir -p $out/logo
    cp $src/logo/gossip.png $out/logo/gossip.png
    mkdir -p $out/share/icons/hicolor/128x128/apps
    ln -s $out/logo/gossip.png $out/share/icons/hicolor/128x128/apps/gossip.png
  '';

  postFixup = ''
    patchelf $out/bin/gossip \
      --add-rpath ${
        lib.makeLibraryPath [
          libGL
          libxkbcommon
          wayland
          wayland-scanner
        ]
      }
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Gossip";
      exec = "gossip";
      icon = "gossip";
      comment = meta.description;
      desktopName = "Gossip";
      categories = [
        "Chat"
        "Network"
        "InstantMessaging"
      ];
      startupWMClass = "gossip";
    })
  ];

  meta = with lib; {
    description = "Desktop client for nostr, an open social media protocol";
    downloadPage = "https://github.com/mikedilger/gossip/releases/tag/${version}";
    homepage = "https://github.com/mikedilger/gossip";
    license = licenses.mit;
    mainProgram = "gossip";
    maintainers = with maintainers; [ msanft ];
    platforms = platforms.unix;
  };
}
