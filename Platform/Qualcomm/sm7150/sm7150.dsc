## @file
#
#  Copyright (c) 2011-2015, ARM Limited. All rights reserved.
#  Copyright (c) 2014, Linaro Limited. All rights reserved.
#  Copyright (c) 2015 - 2016, Intel Corporation. All rights reserved.
#  Copyright (c) 2018 - 2019, Bingxing Wang. All rights reserved.
#  Copyright (c) 2022, Xilin Wu. All rights reserved.
#
#  SPDX-License-Identifier: BSD-2-Clause-Patent
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################

[Defines]
  SOC_PLATFORM            = sm7150
  USE_PHYSICAL_TIMER      = TRUE

!include Silicon/Qualcomm/QcomPkg/QcomCommonDsc.inc

[PcdsFixedAtBuild.common]
  gArmTokenSpaceGuid.PcdSystemMemoryBase|0x080000000         # Starting address
  gArmTokenSpaceGuid.PcdSystemMemorySize|0x20000000000       # Limit to 8GB Size (MODIFIED FOR A71)

  gArmTokenSpaceGuid.PcdCpuVectorBaseAddress|0x9FF8C000     # CPU Vectors
  gArmTokenSpaceGuid.PcdArmArchTimerFreqInHz|19200000
  gArmTokenSpaceGuid.PcdArmArchTimerSecIntrNum|17
  gArmTokenSpaceGuid.PcdArmArchTimerIntrNum|18
  gArmTokenSpaceGuid.PcdGicDistributorBase|0x17a00000
  gArmTokenSpaceGuid.PcdGicRedistributorsBase|0x17a60000

  gEfiMdeModulePkgTokenSpaceGuid.PcdAcpiDefaultOemRevision|0x00007150
  gEmbeddedTokenSpaceGuid.PcdPrePiStackBase|0x9FF90000      # UEFI Stack
  gEmbeddedTokenSpaceGuid.PcdPrePiStackSize|0x00040000      # 256K stack
  gEmbeddedTokenSpaceGuid.PcdPrePiCpuIoSize|44

  gQcomTokenSpaceGuid.PcdUefiMemPoolBase|0xC0000000         # DXE Heap base address
  gQcomTokenSpaceGuid.PcdUefiMemPoolSize|0x0E000000         # UefiMemorySize, DXE heap size
  gQcomTokenSpaceGuid.PcdMipiFrameBufferAddress|0x9C000000

  gArmPlatformTokenSpaceGuid.PcdCoreCount|8
  gArmPlatformTokenSpaceGuid.PcdClusterCount|2

  gQcomTokenSpaceGuid.PcdDebugUartPortBase|0xa88000

  #
  # SimpleInit
  #
  gSimpleInitTokenSpaceGuid.PcdDeviceTreeStore|0x9DA00000
  gSimpleInitTokenSpaceGuid.PcdLoggerdUseConsole|FALSE

[LibraryClasses.common]
  # ACPI Dynamic Tables Framework Libraries (ADDED FOR ACPI SUPPORT)
  DynamicTableFactoryLib|DynamicTablesPkg/Library/Common/DynamicTableFactoryLib/DynamicTableFactoryLib.inf
  DynamicTableHelperLib|DynamicTablesPkg/Library/Common/DynamicTableHelperLib/DynamicTableHelperLib.inf
  ConfigurationManagerLib|DynamicTablesPkg/Library/Common/ConfigurationManagerLib/ConfigurationManagerLib.inf
  FdtHelperLib|EmbeddedPkg/Library/FdtHelperLib/FdtHelperLib.inf

  # Ported from SurfaceDuoPkg
  # AslUpdateLib|Silicon/Qualcomm/QcomPkg/Library/DxeAslUpdateLib/DxeAslUpdateLib.inf

  PlatformMemoryMapLib|Silicon/Qualcomm/sm7150/Library/PlatformMemoryMapLib/PlatformMemoryMapLib.inf
  PlatformPeiLib|Silicon/Qualcomm/sm7150/Library/PlatformPeiLib/PlatformPeiLib.inf
  PlatformPrePiLib|Silicon/Qualcomm/sm7150/Library/PlatformPrePiLib/PlatformPrePiLib.inf
  MsPlatformDevicesLib|Silicon/Qualcomm/sm7150/Library/MsPlatformDevicesLib/MsPlatformDevicesLib.inf
  SOCSmbiosInfoLib|Silicon/Qualcomm/sm7150/Library/SOCSmbiosInfoLib/SOCSmbiosInfoLib.inf

[LibraryClasses.common.DXE_DRIVER]
  DynamicTableFactoryLib|DynamicTablesPkg/Library/Common/DynamicTableFactoryLib/DynamicTableFactoryLib.inf
  DynamicTableHelperLib|DynamicTablesPkg/Library/Common/DynamicTableHelperLib/DynamicTableHelperLib.inf

[Components.common]
  #
  # ACPI Dynamic Tables Framework (ADDED FOR ACPI SUPPORT)
  #
  DynamicTablesPkg/Drivers/DynamicTableManagerDxe/DynamicTableManagerDxe.inf

  #
  # Configuration Manager for sm7150 (ADDED FOR ACPI SUPPORT)
  #
  Silicon/Qualcomm/sm7150/AcpiTables/ConfigurationManager/ConfigurationManagerDxe.inf

  #
  # I2C Driver (ESSENTIAL FOR TOUCHSCREEN)
  #
  Silicon/Qualcomm/QcomPkg/Drivers/I2cDxe/I2cDxe.inf

  #
  # USB Driver (ESSENTIAL FOR USB)
  #
  Silicon/Qualcomm/QcomPkg/Drivers/UsbDeviceDxe/UsbDeviceDxe.inf