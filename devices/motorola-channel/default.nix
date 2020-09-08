{ mobile-nixos
, fetchFromGitHub
, kernelPatches ? []
, dtbTool
, buildPackages
}:
let inherit (buildPackages) dtc; in
(mobile-nixos.kernel-builder-gcc6 {
  version = "3.18.71";
  configfile = ./config.aarch64;
  file = "Image.gz-dtb";
  hasDTB = true;
  src = fetchFromGitHub {
    owner = "lineageos";
    repo = "android_kernel_motorola_sdm632";
    rev = "fdf058fc29fc24859708b2afeb04d866436dda68";
    sha256 = "13p326acpyqvlh5524bvy2qkgzgyhwxgy0smlwmcdl6y7yi04rg5";
  };
  patches = [
    ./99_framebuffer.patch
    ./0003-arch-arm64-Add-config-option-to-fix-bootloader-cmdli.patch
  ];

  postPatch = ''
    # Remove -Werror from all makefiles
    local i
    local makefiles="$(find . -type f -name Makefile)
    $(find . -type f -name Kbuild)"
    for i in $makefiles; do
      sed -i 's/-Werror-/-W/g' "$i"
      sed -i 's/-Werror//g' "$i"
    done
    echo "Patched out -Werror"
  '';

  makeFlags = [ "DTC_EXT=${dtc}/bin/dtc" ];

  isModular = false;
}).overrideAttrs ({ postInstall ? "", postPatch ? "", ... }: {
  installTargets = [ "Image.gz" "zinstall" "Image.gz-dtb" "install" ];
  postInstall = postInstall + ''
    cp $buildRoot/arch/arm64/boot/Image.gz-dtb $out/
  '';
})
