{
  lib,
  fetchFromGitHub,
  symlinkJoin,
  llvmPackages_17,
  lld_17,
  python3,
  cmake,
  boost,
  libxml2,
  libffi,
  makeWrapper,
  config,
  cudaPackages,
  rocmPackages_6,
  ompSupport ? true,
  openclSupport ? false,
  rocmSupport ? config.rocmSupport,
  cudaSupport ? config.cudaSupport,
  autoAddDriverRunpath,
  callPackage,
  nix-update-script,
}:
let
  inherit (llvmPackages) stdenv;
  rocmPackages = rocmPackages_6;
  llvmPackages = llvmPackages_17;
  lld = lld_17;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "adaptivecpp";
  version = "24.06.0";

  src = fetchFromGitHub {
    owner = "AdaptiveCpp";
    repo = "AdaptiveCpp";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-TPa2DT66bGQ9VfSXaFUDuE5ng5x5fiLC2bqQ+ZVo9LQ=";
  };

  #patches = [./rocm-linking.patch];

  rocmMerged = symlinkJoin {
    name = "rocm-merged";
    paths = with rocmPackages; [
      clr
      rocm-device-libs
      rocm-runtime
    ];
  };

  nativeBuildInputs =
    [
      cmake
      makeWrapper
    ]
    ++ lib.optionals cudaSupport [
      autoAddDriverRunpath
      cudaPackages.cuda_nvcc
    ];

  buildInputs =
    [
      libxml2
      libffi
      boost
      python3
      lld
      llvmPackages.openmp
      llvmPackages.libclang.dev
      llvmPackages.llvm
    ]
    ++ lib.optionals rocmSupport [
      finalAttrs.rocmMerged
    ]
    ++ lib.optionals cudaSupport [
      cudaPackages.cuda_cudart
      (lib.getOutput "stubs" cudaPackages.cuda_cudart)
    ];

  # adaptivecpp makes use of clangs internal headers. Its cmake does not successfully discover them automatically on nixos, so we supply the path manually
  cmakeFlags =
    [
      "-DCLANG_INCLUDE_PATH=${llvmPackages.libclang.dev}/include"
      (lib.cmakeBool "WITH_CPU_BACKEND" ompSupport)
      (lib.cmakeBool "WITH_CUDA_BACKEND" cudaSupport)
      (lib.cmakeBool "WITH_ROCM_BACKEND" rocmSupport)
    ]
    ++ lib.optionals (lib.versionAtLeast finalAttrs.version "24") [
      (lib.cmakeBool "WITH_OPENCL_BACKEND" openclSupport)
    ];

  # this hardening option breaks rocm builds
  hardeningDisable = [ "zerocallusedregs" ];

  #postFixup = lib.optionalString rocmSupport
  #  ''
  #    #for b in acpp syclcc syclcc-clang
  #    #do
  #    #  wrapProgram $out/bin/$b \
  #    #    --add-flags "--rocm-device-lib-path=${rocmPackages.rocm-device-libs}/amdgcn/bitcode"
  #    #done
  #    #wrapProgram $out/bin/acpp \
  #    #    --add-flags "--rocm-device-lib-path=${rocmPackages.rocm-device-libs}/amdgcn/bitcode"
  #
  #      cat <<EOF > $out/etc/AdaptiveCpp/acpp-rocm.json
  #      {
  #        "default-rocm-path" : "${rocmPackages.clr}",
  #        "default-rocm-link-line" : "-Wl,-rpath=${rocmPackages.clr}/lib -Wl,-rpath=${rocmPackages.clr}/hip/lib -L${rocmPackages.clr} -L${rocmPackages.clr} -lamdhip64",
  #        "default-rocm-cxx-flags" : "-isystem $out/include/AdaptiveCpp/hipSYCL/std/hiplike -isystem ${llvmPackages.libclang.dev}/include -U__FLOAT128__ -U__SIZEOF_FLOAT128__ -I${rocmPackages.clr}/include --rocm-device-libs-path=${rocmPackages.rocm-device-libs}/amdgcn/bitcode --rocm-path=${rocmPackages.clr} -fhip-new-launch-api -mllvm -amdgpu-early-inline-all=true -mllvm -amdgpu-function-calls=false -D__HIP_ROCclr__"
  #      }
  #      EOF
  #    '';

  passthru = {
    # For tests
    inherit (finalAttrs) nativeBuildInputs buildInputs;

    tests = {
      sycl = callPackage ./tests.nix { };
    };

    updateScript = nix-update-script { };
  };

  meta = with lib; {
    homepage = "https://github.com/AdaptiveCpp/AdaptiveCpp";
    description = "Multi-backend implementation of SYCL for CPUs and GPUs";
    maintainers = with maintainers; [ yboettcher ];
    license = licenses.bsd2;
  };
})
