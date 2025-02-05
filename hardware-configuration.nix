{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.initrd = {
    availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
    kernelModules = [ "nvme" ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/cloudimg-rootfs";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/UEFI";
      fsType = "vfat";
    };
  };
}
