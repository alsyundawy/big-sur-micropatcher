#!/bin/bash
#
# This script will modify according to the needs of this thread:
#
# https://forums.macrumors.com/threads/2011-imac-graphics-card-upgrade.1596614/
#
#===========================================================================

#=====================
# Commands
#=====================
ADD="plutil -insert"
SET="plutil -replace"
DEL="plutil -remove"
BUD="/usr/libexec/PlistBuddy -c"

#==============================================================
# Custom Data - Generate your own PciRoot values and put here!
# See CDF's guide
#==============================================================

GPU0='PciRoot(0x0)/Pci(0x3,0x0)/Pci(0x0,0x0)'
GPU1='PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0)'
SPOOF='Mac-7BA5B2D9E42DDD94'
BVERSION='9999.999.999.999.999'

#============================
# Command line args
#============================

while getopts 'ub' OPTION; do
    case "$OPTION" in
        u)
           MODE="update"
           echo "Creating config.plist for update mode"
           ;;
        ?)
           echo "Usage: $0 [-u] filname"
           echo
           echo "   -u : Create Updatable OC configuration"
           exit 1
           ;;
    esac
done

shift "$((OPTIND -1))"

if [ $# -lt 1 ]
then
   echo "ERROR, missing filename"
   echo
   echo "Usage: $0 [-u] filname"
   echo
   echo "   -u : Create Updatable OC configuration"
   exit 1
fi

FILE="$1"

#====================================================
# backup the input file, it will be written in place
#====================================================
#STAMP=`date +%s`
#cp $FILE ${FILE}.${STAMP}.bak

#============================================
# Basic Configuration - post install Catalina
#============================================

if [ "${MODE}" != "update" ]
then
    $SET Kernel.Emulate.Cpuid1Mask -data "AAAAAAAAAAAAAAAAAAAAAA==" $FILE
fi

$SET UEFI.Output.DirectGopRendering -bool "false" $FILE
# $SET NVRAM.Add.4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14.UIScale -data "Ag==" $FILE

# SKIP - don't change background color
# $SET NVRAM.Add.4D1EDE05-38C7-4A6A-9CC6-4BCCA8B38C14.DefaultBackgroundColor -string "AAAAAA==" $FILE
# $SET Misc.Boot.ConsoleAttributes -integer 0 $FILE

# SKIP - don't turn off boot picker
# $SET Misc.Boot.ShowPicker -bool "false" $FILE

# SKIP - don't enable recovery volumes
# $SET Misc.Boot.HideAuxiliary -bool "false" $FILE


#=====================================
# Advanced Configuration
#=====================================

#
# Lynndale boot patch
# 21.5 and 27 inch iMac 2011 DSDT patch to enable sound
#

$BUD 'Add :ACPI:Add:0 dict' $FILE

$ADD ACPI.Add.0.Comment -string "iMac 2009/2010 Big Sur boot enabler" $FILE
$ADD ACPI.Add.0.Enabled -bool "true" $FILE
$ADD ACPI.Add.0.Path -string "SSDT-CPBG.aml" $FILE

$BUD 'Add :ACPI:Add:1 dict' $FILE

$ADD ACPI.Add.1.Comment -string "only enable on 2011 21.5'' iMac for UEFI WIN10 sound support" $FILE
$ADD ACPI.Add.1.Enabled -bool "false" $FILE
$ADD ACPI.Add.1.Path -string "DSDT_Err_12_fix_21,5''.aml" $FILE

$BUD 'Add :ACPI:Add:2 dict' $FILE

$ADD ACPI.Add.2.Comment -string "only enable on 2011 27.5'' iMac for UEFI WIN10 sound support" $FILE
$ADD ACPI.Add.2.Enabled -bool "false" $FILE
$ADD ACPI.Add.2.Path -string "DSDT_Err_12_fix_27''.aml" $FILE


#===================
# Lilu
#===================

$BUD 'Add :Kernel:Add:0 dict' $FILE

$ADD Kernel.Add.0.Arch -string "x86_64" $FILE
$ADD Kernel.Add.0.BundlePath -string "Lilu.kext" $FILE
$ADD Kernel.Add.0.Comment -string "Patch Engine" $FILE
$ADD Kernel.Add.0.Enabled -bool "true" $FILE
$ADD Kernel.Add.0.ExecutablePath -string "Conents/MacOS/Lilu" $FILE
$ADD Kernel.Add.0.MaxKernel -string "" $FILE
$ADD Kernel.Add.0.MinKernel -string "" $FILE
$ADD Kernel.Add.0.PlistPath -string "Contents/info.plist" $FILE

#===================
# WhateverGreen
#===================

$BUD 'Add :Kernel:Add:1 dict' $FILE

$ADD Kernel.Add.1.Arch -string "x86_64" $FILE
$ADD Kernel.Add.1.BundlePath -string "WhateverGreen.kext" $FILE
$ADD Kernel.Add.1.Comment -string "Video Patch Engine" $FILE
$ADD Kernel.Add.1.Enabled -bool "true" $FILE
$ADD Kernel.Add.1.ExecutablePath -string "Conents/MacOS/WhateverGreen" $FILE
$ADD Kernel.Add.1.MaxKernel -string "" $FILE
$ADD Kernel.Add.1.MinKernel -string "" $FILE
$ADD Kernel.Add.1.PlistPath -string "Contents/info.plist" $FILE

#===================
# AppleBacklightFixup.kext
#===================

$BUD 'Add :Kernel:Add:2 dict' $FILE

$ADD Kernel.Add.2.Arch -string "x86_64" $FILE
$ADD Kernel.Add.2.BundlePath -string "AppleBacklightFixup.kext" $FILE
$ADD Kernel.Add.2.Comment -string "NVIDIA only" $FILE
$ADD Kernel.Add.2.Enabled -bool "false" $FILE
$ADD Kernel.Add.2.ExecutablePath -string "Contents/MacOS/AppleBacklightFixup" $FILE
$ADD Kernel.Add.2.MaxKernel -string "" $FILE
$ADD Kernel.Add.2.MinKernel -string "15.0.0" $FILE
$ADD Kernel.Add.2.PlistPath -string "Contents/info.plist" $FILE


#===================
# FakeSMCKeyStore.kext
#===================

$BUD 'Add :Kernel:Add:3 dict' $FILE

$ADD Kernel.Add.3.Arch -string "x86_64" $FILE
$ADD Kernel.Add.3.BundlePath -string "FakeSMCKeyStore.kext" $FILE
$ADD Kernel.Add.3.Comment -string "SMC KeyStore only (safe?)" $FILE
$ADD Kernel.Add.3.Enabled -bool "false" $FILE
$ADD Kernel.Add.3.ExecutablePath -string "Contents/MacOS/FakeSMC" $FILE
$ADD Kernel.Add.3.MaxKernel -string "" $FILE
$ADD Kernel.Add.3.MinKernel -string "" $FILE
$ADD Kernel.Add.3.PlistPath -string "Contents/info.plist" $FILE

#===================
# FakeSMC_CPUSensors.kext
#===================

$BUD 'Add :Kernel:Add:4 dict' $FILE

$ADD Kernel.Add.4.Arch -string "x86_64" $FILE
$ADD Kernel.Add.4.BundlePath -string "FakeSMC_CPUSensors.kext" $FILE
$ADD Kernel.Add.4.Comment -string "HW Monitor" $FILE
$ADD Kernel.Add.4.Enabled -bool "false" $FILE
$ADD Kernel.Add.4.ExecutablePath -string "Contents/MacOS/CPUSensors" $FILE
$ADD Kernel.Add.4.MaxKernel -string "" $FILE
$ADD Kernel.Add.4.MinKernel -string "" $FILE
$ADD Kernel.Add.4.PlistPath -string "Contents/info.plist" $FILE

#===================
# FakeSMC_GPUSensors.kext
#===================

$BUD 'Add :Kernel:Add:5 dict' $FILE

$ADD Kernel.Add.5.Arch -string "x86_64" $FILE
$ADD Kernel.Add.5.BundlePath -string "FakeSMC_GPUSensors.kext" $FILE
$ADD Kernel.Add.5.Comment -string "NVIDIA only" $FILE
$ADD Kernel.Add.5.Enabled -bool "false" $FILE
$ADD Kernel.Add.5.ExecutablePath -string "Contents/MacOS/GPUSensors" $FILE
$ADD Kernel.Add.5.MaxKernel -string "" $FILE
$ADD Kernel.Add.5.MinKernel -string "" $FILE
$ADD Kernel.Add.5.PlistPath -string "Contents/info.plist" $FILE

#===================
# EFICheckDisabler.kext
#===================

$BUD 'Add :Kernel:Add:6 dict' $FILE

$ADD Kernel.Add.6.Arch -string "x86_64" $FILE
$ADD Kernel.Add.6.BundlePath -string "EFICheckDisabler.kext" $FILE
$ADD Kernel.Add.6.Comment -string "EG firmware modded systems only" $FILE
$ADD Kernel.Add.6.Enabled -bool "false" $FILE
$ADD Kernel.Add.6.ExecutablePath -string "" $FILE
$ADD Kernel.Add.6.MaxKernel -string "" $FILE
$ADD Kernel.Add.6.MinKernel -string "" $FILE
$ADD Kernel.Add.6.PlistPath -string "Contents/info.plist" $FILE

#===================
# telemetrap.kext
#===================

$BUD 'Add :Kernel:Add:7 dict' $FILE

$ADD Kernel.Add.7.Arch -string "x86_64" $FILE
$ADD Kernel.Add.7.BundlePath -string "telemetrap.kext" $FILE
$ADD Kernel.Add.7.Comment -string "Big Sur, only" $FILE
$ADD Kernel.Add.7.Enabled -bool "false" $FILE
$ADD Kernel.Add.7.ExecutablePath -string "Contents/MacOS/telemetrap" $FILE
$ADD Kernel.Add.7.MaxKernel -string "" $FILE
$ADD Kernel.Add.7.MinKernel -string "" $FILE
$ADD Kernel.Add.7.PlistPath -string "Contents/info.plist" $FILE


#==========================
# DeviceProperties
#==========================
#
# /usr/libexec/PlistBuddy -c 'Print :DeviceProperties:Add:PciRoot(0x0)/Pci(0x3,0x0)/Pci(0x0,0x0):@0,built-in' ./config_AMD_BigSur.plist > /tmp/VAL.bin
#
# truncate -s -1 /tmp/VAL.bin
# cp /tmp/VAL.bin ./DEVPROVAL.bin
#
# <01000000> DEVPROVAL.bin


$BUD "Add :DeviceProperties:Add:${GPU0} dict" $FILE
$BUD "Import :DeviceProperties:Add:${GPU0}:@0,backlight-control DEVPROVAL.bin" $FILE
$BUD "Import :DeviceProperties:Add:${GPU0}:@0,built-in DEVPROVAL.bin" $FILE

$BUD "Add :DeviceProperties:Add:${GPU1} dict" $FILE
$BUD "Import :DeviceProperties:Add:${GPU1}:@0,backlight-control DEVPROVAL.bin" $FILE
$BUD "Import :DeviceProperties:Add:${GPU1}:@0,built-in DEVPROVAL.bin" $FILE


#$BUD "Add :DeviceProperties:Add:${GPU1}:@0,built-in" $FILE
#$SET 'DeviceProperties.Add.PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0).@0,built-in' -data 'AAEAAAAAAAA=' $FILE
#
# this throws an exception, the @0 ist not correctly interpreted
# "this class is not key value coding-compliant for the key --> 0,built-in."
#


#$ADD "DeviceProperties.Add.${GPU}.agdpmod" -data 'cGlrZXJhAA==' $FILE
#$ADD "DeviceProperties.Add.${GPU}.rebuild-device-tree" -data 'AA==' $FILE
#$ADD "DeviceProperties.Add.${GPU}.shikigva" -data 'UA==' $FILE


#=============================
# Hybridization - Spoofing
#=============================

$BUD "Add :PlatformInfo:SMBIOS dict" $FILE

$ADD PlatformInfo.SMBIOS.BoardProduct -string "${SPOOF}" $FILE
$ADD PlatformInfo.SMBIOS.BIOSVersion -string "${BVERSION}" $FILE

if [ "${MODE}" != "update" ]
then
    $SET PlatformInfo.UpdateSMBIOS -bool "true" $FILE
fi

#=================================
# Setup NVRAM
#=================================

# TODO, probably should verify before delete, using some bash logic

#$BUD 'Delete :NVRAM:Delete:7C436110-AB2A-4BBB-A880-FE41995C9F82:0' $FILE

$BUD "Add :NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82 dict" $FILE

$SET NVRAM.Add.7C436110-AB2A-4BBB-A880-FE41995C9F82.boot-args -string "-lilubetaall -wegbeta debug=0x100 keepsyms=1 amfi_allow_any_signature=1 agdpmod=pikera shikigva=80 unfairgva=1 mbasd=1 -wegtree -no_compat_check" $FILE

# INSTALL
#$SET NVRAM.Add.7C436110-AB2A-4BBB-A880-FE41995C9F82.boot-args -string "-v keepsyms=1 -no_compat_check debug=0x100" $FILE

# NVIDIA
#$SET NVRAM.Add.7C436110-AB2A-4BBB-A880-FE41995C9F82.boot-args -string "debug=0x100 keepsyms=1 amfi_allow_any_signature=1  -no_compat_check" $FILE

-lilubetaall -wegbeta debug=0x100 keepsyms=1 amfi_allow_any_signature=1 agdpmod=pikera shikigva=80 unfairgva=1 mbasd=1 -wegtree -no_compat_check


$SET NVRAM.Add.7C436110-AB2A-4BBB-A880-FE41995C9F82.run-efi-updater -string "No" $FILE

$BUD 'Import :NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:csr-active-config CSRVAL.bin' $FILE
# <FF0F0000>

$BUD 'Import :NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:SystemAudioVolume AUDIOVAL.bin' $FILE
# <25>


#=====================================
# External Drives as Internal
#=====================================

#$BUD "Add :DeviceProperties:Add:${IDISK} dict" $FILE
#$ADD "DeviceProperties.Add.${IDISK}.built-in" -data 'AA==' $FILE

#==================================
# OpenCanopy
#==================================

# Set - OpenCanopy
$SET Misc.Boot.PickerMode -string "External" $FILE
$SET Misc.Boot.PickerVariant -string "Modern" $FILE
$SET Misc.Boot.PickerAttributes -integer 1 $FILE
$SET Misc.Boot.ConsoleAttributes -integer 0 $FILE
$SET Misc.Boot.TimeOut -integer 10 $FILE
$SET Misc.Boot.TakeOffDelay -integer 2500 $FILE

$SET Misc.Boot.ShowPicker -bool "true" $FILE
$SET Misc.Boot.HideAuxiliary -bool "true" $FILE
$SET Misc.Boot.PollAppleHotkeys -bool "true" $FILE

$ADD UEFI.Drivers.1 -string "OpenCanopy.efi" $FILE

#===============================
# Extra stuff beyond CDF guide
#===============================

#====================================
# Verify the config.plist
#====================================
plutil -convert xml1 config.plist && plutil config.plist
