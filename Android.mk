# Vendor blob tree for the Meizu MX6 (m95) on LineageOS 20 (Android 13).
# Blobs land in the real /vendor image (the `custom` partition); see
# m95-vendor.mk.  Hand-maintained — see device/meizu/m95/setup-makefiles.sh.

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),m95)

# vulkan.mt6797.so -> egl/libGLES_mali.so symlinks. In the stock firmware
# vendor/lib{,64}/hw/vulkan.mt6797.so is a symlink to the Mali blob; the
# sdat2img extraction turned symlinks into text files, so recreate at build.
include $(CLEAR_VARS)
LOCAL_MODULE := vulkan.mt6797_symlinks
LOCAL_MODULE_CLASS := FAKE
LOCAL_MODULE_TAGS := optional
include $(BUILD_SYSTEM)/base_rules.mk
$(LOCAL_BUILT_MODULE): TARGET := /vendor/lib/egl/libGLES_mali.so
$(LOCAL_BUILT_MODULE): SYMLINK := $(TARGET_OUT_VENDOR)/lib/hw/vulkan.mt6797.so
$(LOCAL_BUILT_MODULE): TARGET64 := /vendor/lib64/egl/libGLES_mali.so
$(LOCAL_BUILT_MODULE): SYMLINK64 := $(TARGET_OUT_VENDOR)/lib64/hw/vulkan.mt6797.so
$(LOCAL_BUILT_MODULE):
	$(hide) mkdir -p $(dir $@)
	$(hide) mkdir -p $(dir $(SYMLINK)) $(dir $(SYMLINK64))
	$(hide) rm -f $(SYMLINK) $(SYMLINK64)
	$(hide) ln -sf $(TARGET) $(SYMLINK)
	$(hide) ln -sf $(TARGET64) $(SYMLINK64)
	$(hide) touch $@

# librilimp: the stock MTK libril (proprietary/vendor/lib64/librilmtk.so) with
# its DT_SONAME rewritten to librilimp.so (tools/patches/librilmtk-rename-soname.py).
# It exists only to supply the 11 modem-internal symbols mtk-ril.so imports and
# our AOSP libril does not implement (isMalSupported, isEpdgSupport,
# IMS_RILA_register, ...). hardware/ril/libril builds librilmtk (OUR libril under
# the soname mtk-ril.so already needs) with librilimp in DT_NEEDED, so the vendor
# blob's RIL_onRequestComplete binds to our pending-request list. See
#  the bring-up notes and the bring-up notes
#
# LOCAL_CHECK_ELF_FILES := false is load-bearing: R's check_elf_file.py insists
# every DT_NEEDED of a prebuilt be a build module, and this blob needs libaed /
# libmdfx / libsysenv, which only exist as PRODUCT_COPY_FILES blobs. That check
# is what got this stanza deleted in phase 2; disabling it is the documented
# escape hatch (build/make/core/check_elf_file.mk:41).
include $(CLEAR_VARS)
LOCAL_MODULE := librilimp
LOCAL_MODULE_OWNER := meizu
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_SUFFIX := .so
LOCAL_SRC_FILES := proprietary/vendor/lib64/librilimp.so
LOCAL_MULTILIB := 64
LOCAL_PROPRIETARY_MODULE := true
LOCAL_CHECK_ELF_FILES := false
LOCAL_STRIP_MODULE := false
include $(BUILD_PREBUILT)

endif

# The Flyme camera as privileged system app (proven on LOS16: shutter writes
# a file; full-res path fixed later). PRESIGNED, no dexpreopt.
# APK-PENDING: include $(CLEAR_VARS)
# APK-PENDING: LOCAL_MODULE := MzCamera
# APK-PENDING: LOCAL_MODULE_OWNER := meizu
# APK-PENDING: LOCAL_MODULE_TAGS := optional
# APK-PENDING: LOCAL_MODULE_CLASS := APPS
# APK-PENDING: LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
# APK-PENDING: LOCAL_SRC_FILES := proprietary/system/priv-app/MzCamera/MzCamera.apk
# APK-PENDING: LOCAL_PREBUILT_JNI_LIBS := \
# APK-PENDING:     @lib/armeabi-v7a/libagegendersdk.so     @lib/armeabi-v7a/libarcsoft_face_alignment.so     @lib/armeabi-v7a/libarcsoft_picselfie_algorithm.so     @lib/armeabi-v7a/libarlicense.so     @lib/armeabi-v7a/libbokehalgorithmsdk.so     @lib/armeabi-v7a/libfbalgorithmsdk4.so     @lib/armeabi-v7a/libfbalgorithmsdk.so     @lib/armeabi-v7a/libFlymeFixLinker.so     @lib/armeabi-v7a/libfunny_cam.so     @lib/armeabi-v7a/libglrenderer.so     @lib/armeabi-v7a/libjpeg.so     @lib/armeabi-v7a/libmpbase.so     @lib/armeabi-v7a/libmz_photo_timestamp.so     @lib/armeabi-v7a/libPanoramaStitcherForOreoCamera1.so     @lib/armeabi-v7a/libPanoramaStitcherForOreo.so     @lib/armeabi-v7a/libPanoramaStitcher.so     @lib/armeabi-v7a/libsecret.so     @lib/armeabi-v7a/libsnutil.so     @lib/armeabi-v7a/libsurfacetexture_bitmap.so     @lib/armeabi-v7a/libtensorflowlite_jni.so     @lib/armeabi-v7a/libyuv.so     @lib/armeabi-v7a/libyuvutil.so
# APK-PENDING: LOCAL_CERTIFICATE := PRESIGNED
# APK-PENDING: LOCAL_PRIVILEGED_MODULE := true
# APK-PENDING: LOCAL_DEX_PREOPT := false
# APK-PENDING: include $(BUILD_PREBUILT)
# APK-PENDING: 
# Google Camera (Arnova 5.1.018 v1.7 — the build that photographs here).
# APK-PENDING: include $(CLEAR_VARS)
# APK-PENDING: LOCAL_MODULE := M95GoogleCamera
# APK-PENDING: LOCAL_MODULE_OWNER := google
# APK-PENDING: LOCAL_MODULE_TAGS := optional
# APK-PENDING: LOCAL_MODULE_CLASS := APPS
# APK-PENDING: LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
# APK-PENDING: LOCAL_SRC_FILES := proprietary/system/app/M95GoogleCamera/M95GoogleCamera.apk
# APK-PENDING: LOCAL_CERTIFICATE := PRESIGNED
# APK-PENDING: LOCAL_DEX_PREOPT := false
# APK-PENDING: include $(BUILD_PREBUILT)
# APK-PENDING: 
# GCam Services Provider (no GMS on this device).
# APK-PENDING: include $(CLEAR_VARS)
# APK-PENDING: LOCAL_MODULE := M95GCamServices
# APK-PENDING: LOCAL_MODULE_OWNER := lukaspieper
# APK-PENDING: LOCAL_MODULE_TAGS := optional
# APK-PENDING: LOCAL_MODULE_CLASS := APPS
# APK-PENDING: LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
# APK-PENDING: LOCAL_SRC_FILES := proprietary/system/app/M95GCamServices/M95GCamServices.apk
# APK-PENDING: LOCAL_CERTIFICATE := PRESIGNED
# APK-PENDING: LOCAL_DEX_PREOPT := false
# APK-PENDING: include $(BUILD_PREBUILT)
# APK-PENDING: 