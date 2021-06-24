{ stdenv, pkgs, lib, beamPackages, fetchFromGitHub, fetchFromGitLab, fetchHex }:

let
  gitignoreSrc = fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    rev = "211907489e9f198594c0eb0ca9256a1949c9d412";
    sha256 = "sha256-qHu3uZ/o9jBHiA3MEKHJ06k7w4heOhA+4HCSIvflRxo=";
  };
  inherit (import gitignoreSrc { inherit (pkgs) lib; }) gitignoreSource;

  randomx = fetchFromGitHub {
    owner = "arweaveteam";
    repo = "RandomX";
    rev = "d64fce8329f85bbafe43ffbfd03284242b13fb1c";
    sha256 = "sha256-+SrRGAasQcwo5gJm646Ci+31y6tJ0lgIAlzaeEez1CU=";
    fetchSubmodules = true;
  };

  b64fast = beamPackages.buildRebar3 rec {
    name = "b64fast";
    version = "5e3d021afe0a634384490e38c8cc11add569b3f7";
    beamDeps = [ beamPackages.pc ];
    src = fetchFromGitHub {
      owner = "arweaveteam";
      repo = name;
      rev = version;
      sha256 = "M4gLlm0x+C6LH1avhJsRNB0vSsjRhelk2ZpysQA8H0I=";
      fetchSubmodules = true;
    };
  };

  rebar3 = beamPackages.rebar3WithPlugins {
    plugins = [ b64fast ];
    globalPlugins = [
      beamPackages.pc
    ];
  };

  rocksdb = pkgs.rocksdb.overrideAttrs(oldAttrs: {
    src = fetchFromGitHub {
      owner = "facebook";
      repo = "rocksdb";
      rev = "d44ef2ed4dbd36afa992191bbefd93106d693312";
      sha256 = "sha256-6ioRrMxbm3CdaZWlPG7VIH+JFSfuBDetU5Agp1hQdFQ=";
    };
  });

  erlang-rocksdb = beamPackages.buildRebar3 rec {
    name = "erlang-rocksdb";
    version = "165d441f543c6be97e2f0df136628a736cabe85f";
    beamDeps = [ beamPackages.pc ];
    nativeBuildInputs = [ pkgs.cmake ];
    configurePhase = "true";
    src = fetchFromGitLab {
      owner = "hlolli";
      repo = name;
      rev = version;
      sha256 = "sha256-UjodnCNETaVwZd8dShJsPHIbePQkujo2wZNKZrRYnro=";
    };
  };


  rebar3_hex = beamPackages.buildRebar3 {
    name = "rebar3_hex";
    version = "none";
    src = fetchFromGitHub {
      owner = "erlef";
      repo = "rebar3_hex";
      rev = "203466094b98fcbed9251efa1deeb69fefd8eb0a";
      sha256 = "gVmoRzinc4MgcdKtqgUBV5/TGeWulP5Cm1pTsSWa07c=";
      fetchSubmodules = true;
    };
  };

  geas_rebar3 = beamPackages.buildRebar3 {
    name = "geas_rebar3";
    version = "none";
    src = fetchFromGitHub {
      owner = "crownedgrouse";
      repo = "geas_rebar3";
      rev = "e3170a36af491b8c427652c0c57290011190b1fb";
      sha256 = "ooMalh8zZ94WlCBcvok5xb7a+7fui4/b+gnEEYpn7fE=";
    };
  };

  graphql = beamPackages.buildRebar3 {
    name = "graphql-erlang";
    version = "none";
    beamDeps = [ beamPackages.pc geas_rebar3 rebar3_hex ];
    buildPlugins = [ geas_rebar3 rebar3_hex ];
    patchPhase = ''
     substituteInPlace src/graphql.erl \
       --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
     substituteInPlace src/graphql_ast.erl \
       --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
     substituteInPlace src/graphql_err.erl \
       --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
     substituteInPlace src/graphql_parser.yrl \
       --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
     substituteInPlace src/graphql_introspection.erl \
       --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
     substituteInPlace src/graphql_execute.erl \
       --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
     substituteInPlace src/graphql_check.erl \
       --replace 'graphql/include/graphql.hrl' 'include/graphql.hrl'
    '';
    src = fetchFromGitHub {
      owner = "jlouis";
      repo = "graphql-erlang";
      rev = "4fd356294c2acea42a024366bc5a64661e4862d7";
      sha256 = "lJ6mEP5ab4GbFzlnbf9U9bAlZ+HGFZLbOZNvTUO1Dhw=";
    };
  };

  accept = beamPackages.buildRebar3 rec {
    name = "accept";
    version = "0.3.5";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-EbGMIgvMLqtjtUcMA47xDrZ4O8sfzbEapBN976WsG7g=";
    };
  };

  prometheus_httpd = beamPackages.buildRebar3 rec {
    name = "prometheus_httpd";
    version = "2.1.11";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-C76DFFLP35WIU46y9XCybzDDSK2uXpWn2H81pZELz5I=";
    };
  };

  prometheus_cowboy = beamPackages.buildRebar3 rec {
    name = "prometheus_cowboy";
    version = "0.1.8";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-uihr7KkwJhhBiJLTe81dxmmmzAAfTrbWr4X/gfP080w=";
    };
  };

  prometheus_process_collector = beamPackages.buildRebar3 {
    name = "prometheus_process_collector";
    version = "1.6.0";
    src = fetchHex {
      pkg = "prometheus_process_collector";
      version = "1.6.0";
      sha256 = "sha256-6c2YRvIE3noEhj9WMI2NEZO+xxQhC/Y3TZ1PwIjSiW0=";
    };

    preBuild = ''
      substituteInPlace c_src/Makefile \
        --replace '-arch x86_64' " "

      make -C c_src
    '';

  };

in stdenv.mkDerivation {

  name = "arweave";
  version = "0.0.0";
  src = gitignoreSource ./.;
  buildInputs = with pkgs; [
    b64fast
    graphql
    prometheus_process_collector
    prometheus_cowboy
    prometheus_httpd
    rebar3
    rocksdb
    erlang-rocksdb
    accept
    cmake
    gmp.dev
    beamPackages.pc
  ];

  postPatch = ''
    sed -i -e 's/{b64fast.*//g' rebar.config
    sed -i -e 's/{graphql.*//g' rebar.config
    sed -i -e 's/{rocksdb.*//g' rebar.config
    sed -i -e 's/rocksdb,//g' rebar.config
    sed -i -e 's/"4.6.0"},/"4.6.0"}/g' rebar.config
    sed -i -e 's/{prometheus_cowboy.*//g' rebar.config
    sed -i -e 's/{prometheus_process_collector.*//g' rebar.config
    sed -i -e 's|apps/arweave/lib/RandomX/build|apps/arweave/lib/RandomX/build \&\& pwd \&\& ls ../|g' rebar.config
    sed -i -e 's|-arch x86_64||g' apps/arweave/c_src/Makefile apps/ar_sqlite3/c_src/Makefile
    rm rebar.lock
  '';

  configurePhase = "true";

  buildPhase = ''
    rm -rf apps/arweave/lib/RandomX
    mkdir -p apps/arweave/lib/RandomX
    cp -rf ${randomx}/* apps/arweave/lib/RandomX
    rm -rf _build

    HOME=$(pwd) rebar3 as prod release
  '';

  installPhase = "mkdir $out; cp -rf ./_build/prod/rel/arweave/* $out";

}
