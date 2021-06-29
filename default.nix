{ nixpkgs ? import (builtins.fetchTarball {
  url = "https://github.com/NixOS/nixpkgs/archive/9de5cbca453657b1b9e52b1e5f081e5afe059b92.tar.gz";
  sha256 = "sha256:0994xhbbv2v1bzji18acj923z4y0gxwr8w13adqvzlihmymyvdjv";
}) {}}:



let
  pkgs = nixpkgs.pkgs;
  gitignoreSrc = fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    rev = "211907489e9f198594c0eb0ca9256a1949c9d412";
    sha256 = "sha256-qHu3uZ/o9jBHiA3MEKHJ06k7w4heOhA+4HCSIvflRxo=";
  };

  inherit (import gitignoreSrc { inherit (pkgs) lib; }) gitignoreSource;
  inherit (pkgs) stdenv lib beamPackages fetchFromGitHub fetchFromGitLab fetchHex;

  randomx = fetchFromGitHub {
    owner = "arweaveteam";
    repo = "RandomX";
    rev = "d64fce8329f85bbafe43ffbfd03284242b13fb1c";
    sha256 = "sha256-+SrRGAasQcwo5gJm646Ci+31y6tJ0lgIAlzaeEez1CU=";
    fetchSubmodules = true;
  };

  buildRebar = beamPackages.buildRebar3.override { openssl = pkgs.openssl; };
  # b64fastSrc = fetchFromGitHub {
  #   owner = "arweaveteam";
  #   repo = "b64fast";
  #   rev = "5e3d021afe0a634384490e38c8cc11add569b3f7";
  #   sha256 = "M4gLlm0x+C6LH1avhJsRNB0vSsjRhelk2ZpysQA8H0I=";
  #   fetchSubmodules = true;
  # };

  b64fast = buildRebar rec {
    name = "b64fast";
    version = "0.2.2";
    beamDeps = [ beamPackages.pc ];
    compilePort = true;

    src = fetchFromGitHub {
      owner = "arweaveteam";
      repo = name;
      rev = "5e3d021afe0a634384490e38c8cc11add569b3f7";
      sha256 = "M4gLlm0x+C6LH1avhJsRNB0vSsjRhelk2ZpysQA8H0I=";
      fetchSubmodules = true;
    };

    postBuild = ''
      env rebar3 pc compile
    '';
  };


  # rocksdb = pkgs.rocksdb.overrideAttrs(oldAttrs: {
  #   src = fetchFromGitHub {
  #     owner = "facebook";
  #     repo = "rocksdb";
  #     rev = "d44ef2ed4dbd36afa992191bbefd93106d693312";
  #     sha256 = "sha256-6ioRrMxbm3CdaZWlPG7VIH+JFSfuBDetU5Agp1hQdFQ=";
  #   };
  # });

  erlang-rocksdb = buildRebar rec {
    name = "erlang-rocksdb";
    version = "165d441f543c6be97e2f0df136628a736cabe85f";
    beamDeps = [ beamPackages.pc ];
    nativeBuildInputs = [ pkgs.cmake ];
    buildInputs = [ pkgs.getconf ];
    configurePhase = "true";
    src = fetchFromGitLab {
      owner = "hlolli";
      repo = name;
      rev = version;
      sha256 = "sha256-UjodnCNETaVwZd8dShJsPHIbePQkujo2wZNKZrRYnro=";
    };
    postInstall = ''
      mv $out/lib/erlang/lib/erlang-rocksdb-${version} $out/lib/erlang/lib/rocksdb-1.6.0
    '';
  };

  meck = buildRebar rec {
    name = "meck";
    version = "0.8.13";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-008BPBVttRrVfMVWiRuXIOahwd9f4uFa+ZnITWzr6xo=";
    };
  };


  rebar3_hex = buildRebar {
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

  geas_rebar3 = buildRebar {
    name = "geas_rebar3";
    version = "none";
    src = fetchFromGitHub {
      owner = "crownedgrouse";
      repo = "geas_rebar3";
      rev = "e3170a36af491b8c427652c0c57290011190b1fb";
      sha256 = "ooMalh8zZ94WlCBcvok5xb7a+7fui4/b+gnEEYpn7fE=";
    };
  };

  graphql = buildRebar {
    name = "graphql-erlang";
    version = "none";
    beamDeps = [ beamPackages.pc geas_rebar3 rebar3_hex ];
    # buildInputs = [ geas_rebar3 rebar3_hex ];
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
    postInstall = ''
      mv $out/lib/erlang/lib/graphql-erlang-none $out/lib/erlang/lib/graphql_erl-0.16.1
    '';
  };

  accept = buildRebar rec {
    name = "accept";
    version = "0.3.5";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-EbGMIgvMLqtjtUcMA47xDrZ4O8sfzbEapBN976WsG7g=";
    };
  };

  double-conversion = fetchFromGitHub {
    owner = "google";
    repo = "double-conversion";
    rev = "32bc443c60c860eb6b4843533a614766d611172e";
    sha256 = "sha256-ysWwhvcVSWnF5HoJW0WB3MYpJ+dvqz3068G/uX9aBlU=";
  };

  jiffy = buildRebar rec {
    name = "jiffy";
    version = "1.0.8";
    setupHook = false;
    NIX_CFLAGS_COMPILE = "-fno-lto -Wno-unused-command-line-argument -faligned-allocation -m64 -arch ${pkgs.stdenv.targetPlatform.linuxArch}";
    NIX_CXXFLAGS_COMPILE = "-faligned-allocation -m64 -arch ${pkgs.stdenv.targetPlatform.linuxArch}";
    NIX_LDFLAGS = "-arch ${pkgs.stdenv.targetPlatform.linuxArch}";
    NIX_CFLAGS_LINK = "-fno-lto";
    REBAR = "${pkgs.beamPackages.rebar3}/bin/rebar3";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.darwin.signingUtils pkgs.llvmPackages.bintools-unwrapped ];
    configureFlags = [ "-fno-lto" ];
    hardeningDisable = [ "all" ];

    src = fetchFromGitHub {
      owner = "davisp";
      repo = name;
      rev = "37039ba32e950480715be74751a53339420a6fe1";
      sha256 = "sha256-t+AixeZ2HONEyyJ69CA7yJ5kWDthJM3c7J6jVriG7l0=";
    };

    postInstall = ''
      sign $out/lib/erlang/lib/jiffy-${version}/priv/jiffy.so
    '';

    patchPhase = ''
      sed -i -e 's|-m64|-m64 -arch ${pkgs.stdenv.targetPlatform.linuxArch} -faligned-allocation|g' rebar.config
      sed -i -e 's|x86_64|${pkgs.stdenv.targetPlatform.linuxArch} -fno-lto -v|g' rebar.config
      sed -i -e 's|darwin9\.\*-64\$|darwin.*|g' rebar.config
      sed -i -e 's|port_env, \[|port_env, [ {"darwin.*", "CFLAGS", "-m64 -arch ${pkgs.stdenv.targetPlatform.linuxArch} -faligned-allocation"}, |g' rebar.config

      sed -i -e 's|-compile.*||g' rebar.config
      rm -rf c_src/double-conversion
      cp -rf ${double-conversion}/double-conversion c_src/double-conversion
      chmod -R +rw c_src/double-conversion
    '';
  };

  prometheus = buildRebar rec {
    name = "prometheus";
    version = "4.6.0";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-SQX9KZL4A47M16oM0i9AY37WGMC+0fdcBarOwVt1Rd4=";
    };
  };

  prometheus_httpd = buildRebar rec {
    name = "prometheus_httpd";
    version = "2.1.11";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-C76DFFLP35WIU46y9XCybzDDSK2uXpWn2H81pZELz5I=";
    };
  };

  prometheus_cowboy = buildRebar rec {
    name = "prometheus_cowboy";
    version = "0.1.8";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-uihr7KkwJhhBiJLTe81dxmmmzAAfTrbWr4X/gfP080w=";
    };
  };

  prometheus_process_collector = buildRebar rec {
    name = "prometheus_process_collector";
    version = "1.6.0";
    buildInputs = [ rebar3_archive_plugin rebar3_hex ];
    CXXFLAGS = "-m64 -arch ${pkgs.stdenv.targetPlatform.linuxArch}";
    LDFLAGS = "-arch ${pkgs.stdenv.targetPlatform.linuxArch}";

    patchPhase = ''
      rm -rf .git
    '';
    # substituteInPlace src/prometheus_process_collector.app.src \
    #     --replace '1.6.0' '1.7.0'
    # src = fetchHex {
    #   inherit version;
    #   pkg = name;
    #   sha256 = "sha256-3Ob675wS1V7YpCl/+yimPRCOIkaWhHzvEredArccmvw=";
    # };
    # substituteInPlace c_src/Makefile \
    #     --replace '-arch x86_64' '-arch {pkgs.stdenv.targetPlatform.linuxArch}'

    src = fetchFromGitHub {
      owner = "deadtrickster";
      repo = name;
      rev = "78697537f01a858959a26a9c74db5aad2971b244";
      sha256 = "sha256-3Bb4d63JMdexzAI68Q+ASsj4FfNxQ9OUlG41fhFkMds=";
    };

    postInstall = ''
      mv $out/lib/erlang/lib/prometheus_process_collector-${version}/priv/source.so \
        $out/lib/erlang/lib/prometheus_process_collector-${version}/priv/prometheus_process_collector.so
    '';
  };

      # substituteInPlace c_src/Makefile \
      #   --replace '-arch x86_64' '-arch ${pkgs.stdenv.targetPlatform.linuxArch}' \
      #   --replace '-lerl_interface' -lstdc++
      # make -C c_src

  rebar3_archive_plugin = buildRebar rec {
    name = "rebar3_archive_plugin";
    version = "0.0.2";
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-hMa0F1EdeazKg3WrLHXSD+zG0OK0C/puDz1i3OsyBYQ=";
    };
  };

  rebar3_elvis_plugin = buildRebar rec {
    name = "rebar3_elvis_plugin";
    version = "0b7dd1a3808dbe2e2e916ecf3afd1ff24e723021";
    src = fetchFromGitHub {
      owner = "deadtrickster";
      repo = name;
      rev = version;
      sha256 = "zM3WPLlbi05aYqMR5AhlNejBaPa6/nSIlq6CG7uNBoo=";
    };
  };

  cowlib = buildRebar rec {
    name = "cowlib";
    version = "e9448e5628c8c1d9083223ff973af8de31a566d1";
    src = fetchFromGitHub {
      owner = "ninenines";
      repo = "cowlib";
      rev = version;
      sha256 = "1j7b602hq9ndh0w3s7jcs923jclmiwfdmbfxaljcra5sl23ydwgf";
    };
  };

  cowboy = buildRebar rec {
    name = "cowboy";
    version = "2.9.0";
    buildInputs = [ cowlib rebar3_archive_plugin ranch ];
    beamDeps = [ cowlib rebar3_archive_plugin ranch ];
    plugins = [ beamPackages.pc ];
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-LHKfk0tOGqFJr/iC9XxjcsFTmaINVPZcjWe+9YMCG94=";
    };
  };

  gun = buildRebar rec {
    name = "gun";
    version = "1.3.2";
    beamDeps = [ beamPackages.pc geas_rebar3 rebar3_hex cowlib ];
    src = fetchHex {
      inherit version;
      pkg = name;
      sha256 = "sha256-ujI/Cl/Yq6w3mj4f5tjOVwxKEsf9HGj0mUtTRHkY5GI=";
    };
  };

  ranch = buildRebar rec {
    name = "ranch";
    version = "a692f44567034dacf5efcaa24a24183788594eb7";
    src = fetchFromGitHub {
      owner = "ninenines";
      repo = name;
      rev = version;
      sha256 = "03naawrq8qpv9al915didl4aicinj79f067isc21dbir0lhn1lgn";
    };
  };

  rebar3_ = beamPackages.rebar3WithPlugins {

    globalPlugins = [
      pkgs.beamPackages.pc
      pkgs.beamPackages.rebar3-nix
      rebar3_archive_plugin
      rebar3_elvis_plugin
    ];
  };


in beamPackages.rebar3Relx {

  name = "arweave";
  version = "0.0.0";
  src = gitignoreSource ./.;
  profile = "prod";
  releaseType = "release";
  plugins = [
    pkgs.beamPackages.pc
    # pkgs.beamPackages.rebar3-nix
    rebar3_archive_plugin
    rebar3_elvis_plugin
  ];

  doStrip = false;

  nativeBuildInputs = with pkgs; [ clang-tools cmake pkg-config ];

  beamDeps = [
    beamPackages.pc
    geas_rebar3
    rebar3_hex
    b64fast
    erlang-rocksdb
    # jiffy
    accept
    gun
    ranch
    cowlib
    # graphql
    meck
    cowboy
    prometheus
    prometheus_process_collector
    prometheus_cowboy
    prometheus_httpd
  ];

  buildInputs = [
    # rebar3_archive_plugin
    # rebar3_elvis_plugin

    # rebar3_
    pkgs.darwin.sigtool
    pkgs.git
    pkgs.gmp
    pkgs.beamPackages.pc
  ];
  # ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin (
  #   with pkgs.darwin; [
  #     # pkgs.clang-tools
  #     # Libc
  #     # Libm
  #     # Libsystem
  #     # sigtool
  #   ]));

  # ERL_LIBS = pkgs.lib.strings.makeSearchPath ":" [
  #   b64fast
  #   cowlib
  #   graphql
  #   cowboy
  #   prometheus
  #   prometheus_cowboy
  #   prometheus_httpd
  #   "${erlang-rocksdb}/lib/erlang/lib"
  #   jiffy
  #   accept
  #   gun
  #   ranch
  # ];

  postConfigure = ''
    rm -rf apps/arweave/lib/RandomX
    mkdir -p apps/arweave/lib/RandomX
    cp -rf ${randomx}/* apps/arweave/lib/RandomX
    cp -rf ${jiffy}/lib/erlang/lib/* apps/jiffy
    cp -rf ${graphql}/lib/erlang/lib/* apps/graphql
  '';

  postPatch = ''
    sed -i -e 's|-arch x86_64|-arch ${pkgs.stdenv.targetPlatform.linuxArch}|g' \
      apps/arweave/c_src/Makefile \
      apps/ar_sqlite3/c_src/Makefile

    # change rocksdb revision for correct bootstrap
    sed -i -e 's|{b64fast,.*|{b64fast, "0.2.2"},|g' rebar.config
    # sed -i -e 's|{rocksdb,.*|{rocksdb, "1.6.0"}|g' rebar.config
    sed -i -e 's|{graphql,.*|{graphql_erl, "0.16.1"},|g' rebar.config
  '';

  installPhase = ''
    mkdir $out; cp -rf ./_build/prod/rel/arweave/* $out
  '';

  postFixup = ''
    codesign -f -s - $out/erts-*/bin/{beam.smp,ct_run,dialyzer,dyn_erl,epmd,erl_call,erl_child_setup,erlc,erlexec,escript,heart,inet_gethost,run_erl,to_erl,typer}
    codesign -f -s - $out/lib/*/priv/*.so
  '';

  # preInstall = ''
  #   sed -i -e 's|SCRIPT_DIR=.*|SCRIPT_DIR=${placeholder "out"}/rel/arweave/bin|g' \
  #     _build/prod/rel/arweave/bin/arweave
  #   sed -i -e 's|"bin/arweave"|"${placeholder "out"}/bin/arweave"|g' \
  #     _build/prod/rel/arweave/bin/start
  # '';

  # postPatch = ''
  #   sed -i -e 's/{b64fast.*//g' rebar.config
  #   sed -i -e 's/{graphql.*//g' rebar.config
  #   sed -i -e 's/{rocksdb.*//g' rebar.config
  #   sed -i -e 's/{jiffy.*//g' rebar.config
  #   sed -i -e 's/jiffy,//g' rebar.config
  #   sed -i -e 's/rocksdb,//g' rebar.config
  #   sed -i -e 's/"4.6.0"},/"4.6.0"}/g' rebar.config
  #   sed -i -e 's/{prometheus_cowboy.*//g' rebar.config
  #   sed -i -e 's/{prometheus_process_collector.*//g' rebar.config
  #   sed -i -e 's|apps/arweave/lib/RandomX/build|apps/arweave/lib/RandomX/build \&\& pwd \&\& ls ../|g' rebar.config
  #   sed -i -e 's|-arch x86_64||g' apps/arweave/c_src/Makefile apps/ar_sqlite3/c_src/Makefile
  #   rm rebar.lock
  # '';

  # postPatch = ''
  #   # rm rebar.lock
  #   cat <<EOF > rebar.config.bak
  #   {plugins, [ pc, rebar3_nix ]}.
  #   {overrides,
  #     [
  #       {override, jiffy, [
  #         {plugins, [pc]},
  #         {artifacts, ["priv/jiffy.so"]},
  #         {provider_hooks, [
  #           {post, [
  #             {compile, {pc, compile}},
  #             {clean, {pc, clean}}
  #           ]}
  #         ]}
  #       ]}
  #     ]}.

  #     {pre_hooks, [
  #       {"(linux|darwin)", compile, "bash -c \"mkdir -p apps/arweave/lib/RandomX/build && cd apps/arweave/lib/RandomX/build && cmake .. > /dev/null\""},
  #       {"(linux|darwin)", compile, "make -C apps/arweave/lib/RandomX/build"},
  #       {"(linux)", compile, "env AR=gcc-ar make -C apps/arweave/c_src"},
  #       {"(darwin)", compile, "make -C apps/arweave/c_src"}
  #     ]}.
  #     {post_hooks, [
  #       {"(linux|darwin)", clean, "bash -c \"if [ -d apps/arweave/lib/RandomX/build ]; then make -C apps/arweave/lib/RandomX/build clean; fi\""},
  #       {"(linux|darwin)", clean, "make -C apps/arweave/c_src clean"}
  #     ]}.
  #     {erl_opts, [
  #       {i, "apps"}
  #     ]}.
  #     {profiles, [
  #       {prod, [
  #         {relx, [
  #           {dev_mode, false},
  #           {include_erts, false},
  #           {system_libs, false}
  #         ]}
  #       ]}
  #     ]}.
  #     {relx, [
  #       {release,
  #         {arweave, "2.4.2.0"},
  #         [
  #           {arweave, load},
  #           ar_sqlite3
  #         ]
  #       },

  #       {sys_config, "./config/sys.config"},
  #       {vm_args_src, "./config/vm.args.src"},
  #       {overlay, [
  #         {copy, "scripts/start", "bin/start"},
  #         {copy, "scripts/stop", "bin/stop"},
  #         {copy, "bin/logs", "bin/logs"},
  #         {copy, "bin/check-nofile", "bin/check-nofile"},
  #         {copy, "scripts/hashrate-upper-limit", "bin/hashrate-upper-limit"},
  #         {copy, "apps/arweave/lib/RandomX/build/randomx-benchmark", "bin/randomx-benchmark"},
  #         {copy, "scripts/remove-old-wallet-lists", "bin/remove-old-wallet-lists"}
  #       ]},
  #       {system_libs, false},
  #       {dev_mode, false},
  #       {include_erts, false},
  #       {generate_start_script, true},
  #       {extended_start_script, true}
  #     ]}.
  #   EOF

  #   sed -i -e 's|-arch x86_64|-arch ${pkgs.stdenv.targetPlatform.linuxArch}|g' \
  #     apps/arweave/c_src/Makefile \
  #     apps/ar_sqlite3/c_src/Makefile

  # '';
  # compilePort = true;

  # configurePhase = "true";

  # CFLAGS = "-m64 -arch ${pkgs.stdenv.targetPlatform.linuxArch}";
  # CXXFLAGS = "-m64 -arch ${pkgs.stdenv.targetPlatform.linuxArch}";
  # LDFLAGS = "-arch ${pkgs.stdenv.targetPlatform.linuxArch}";

  # buildPhase = ''
  #   rm -rf apps/arweave/lib/RandomX
  #   mkdir -p apps/arweave/lib/RandomX
  #   cp -rf ${randomx}/* apps/arweave/lib/RandomX

  #   # cd apps/ar_sqlite3
  #   # HOME=$(pwd) rebar3 nix bootstrap
  #   # cd ../../

  #   # HOME=$(pwd) rebar3 nix bootstrap compile-ports
  #   rm rebar.lock

  #   # # fool rebar3
  #   # git init && git add -A

  #   # for debugging rebar3 installation, uncomment the line below
  #   # HOME=$(pwd) DIAGNOSTIC=1 rebar3 tree || (cat rebar3.crashdump && exit 1)
  #   # chmod -R +rw .
  #   # mkdir -p $out

  #   # we need to copy over the original resources because of rebar3 issue
  #   # for link in $(find ./_build/default/lib -type l)
  #   # do
  #   #   loc="$(dirname "$link")"
  #   #   dir="$(readlink "$link")"
  #   #   rm "$link"
  #   #   cp -rf "$dir" "$loc"
  #   # done
  #   # chmod -R +rw ./_build/default/lib

  #   # HOME=$(pwd) DIAGNOSTIC=1 rebar3 tree || (cat rebar3.crashdump && exit 1)
  #   # ls .cache/rebar3/hex/hexpm/packages
  #   # echo ${prometheus_process_collector.src}

  #   # tar -xf .cache/rebar3/hex/hexpm/packages/prometheus_process_collector-1.6.0.tar
  #   # tar -xf contents.tar.gz
  #   # cat c_src/Makefile
  #   # ls
  #   # stat .cache/rebar3/hex/hexpm/packages/prometheus_process_collector-1.6.0.tar && \
  #   #   cp ${prometheus_process_collector.src} .cache/rebar3/hex/hexpm/packages/prometheus_process_collector-1.6.0.tar

  #   # exit 1
  #   # ls _build/default/lib
  #   # echo 2222
  #   # ls _build/default/lib/prometheus_process_collector-1.6.0/src
  #   # cat _build/default/lib/prometheus_process_collector-1.6.0/src/prometheus_process_collector.erl
  #   # grep -rn x86_64 _build

  #   # aarch64 fix
  #   # sed -i -e 's|-arch x86_64|-arch ${pkgs.stdenv.targetPlatform.linuxArch}|g'  \
  #   #   _build/default/lib/rebar/priv/templates/Makefile \
  #   #   _build/default/lib/pc-1.12.0/src/pc_port_env.erl  || (cat rebar3.crashdump && exit 1)
  #   # rebar3 nix bootstrap

  #   # REBAR_OFFLINE=true REBAR_VENDORED=true HEX_OFFLINE=true HOME=$(pwd) DEBUG=1 DIAGNOSTIC=1
  #   # REBAR_IGNORE_DEPS=1 HOME=$(pwd)

  #   # cd apps/ar_sqlite3
  #   # rebar3 compile
  #   # cd ../../
  #   cp -rf _build apps/ar_sqlite3
  #   cp -rf _build apps/arweave
  #   rebar3 as prod release --override jiffy:$(pwd)/_build/default/lib/jiffy --system_libs
  # '';

  # installPhase = ''
  #   # rebar3 local install
  #   mkdir $out; cp -rf ./_build/prod/rel/arweave/* $out
  # '';

}

        #   {included_applications, [
        #     prometheus_process_collector,
        #     b64fast,
        #     rocksdb,
        #     jiffy
        # ]},

    # mkdir -p _build/default/lib
    # cp -rf ${jiffy}/lib/erlang/lib/* _build/default/lib
      # b64fast,
      # {gun, "${gun.version}"},
      # {cowboy, "${cowboy.version}"},
      # prometheus,
      # {prometheus_cowboy, "${prometheus_cowboy.version}"},
      # prometheus_process_collector,
      # prometheus_httpd
