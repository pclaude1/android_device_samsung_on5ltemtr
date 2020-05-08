USE_CAMERA_STUB := true

# inherit from the proprietary version
-include vendor/Samsung/on5ltemtr/BoardConfigVendor.mk

TARGET_ARCH := arm
TARGET_NO_BOOTLOADER := true
TARGET_BOOTLOADER_BOARD_NAME := universal3475
TARGET_BOARD_PLATFORM := exynos3
TARGET_BOARD_PLATFORM_GPU := ARM Mali-T720
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH_VARIANT := armv7I
TARGET_CPU_VARIANT := cortex-a7
TARGET_CPU_SMP := true
ARCH_ARM_HAVE_TLS_REGISTER := true

TARGET_BOOTLOADER_BOARD_NAME := on5ltemtr

BOARD_KERNEL_CMDLINE := # Exynos doesn't take cmdline arguments from boot image
BOARD_KERNEL_BASE := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048

# fix this up by examining /proc/mtd on a running device
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x0000d00000
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x0000f00000
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 0x00b6800000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 0x00fe000000
BOARD_FLASH_BLOCK_SIZE := 131072

TARGET_PREBUILT_KERNEL := device/Samsung/on5ltemtr/zImage
TARGET_PREBUILT_DTB := device/samsung/on5ltemtr/dtb.img
BOARD_HAS_NO_SELECT_BUTTON := true
