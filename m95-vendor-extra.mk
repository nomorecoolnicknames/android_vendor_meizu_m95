# Hand-maintained vendor additions (survives m95-vendor.mk regeneration).
# libnativehelper (R ART-apex jailbreak): 57 N blobs DT_NEEDED it, but R ships
# it only inside com.android.art apexes, invisible to the vendor namespace
# even under lite. Same-source copy (md5 matches our own R build output).
#
# It goes to lib{,64}/hw, NOT lib{,64}: under VNDK-lite linkerconfig puts
# /vendor/${LIB} into the SYSTEM default namespace search path too
# (systemdefault.cc: !is_fully_treblelized), and search paths win over the
# com_android_art link, so app_process64 mapped /vendor/lib64/libnativehelper.so
# (avc line, 2026-09-04 v6 boot) and zygote died with SIGSEGV on every start.
# /vendor/${LIB}/hw is searched by the vendor default and sphal namespaces
# (vendordefault.cc:95, sphal.cc:44) but not by the system one.
PRODUCT_COPY_FILES += \
    vendor/meizu/m95/proprietary/vendor/lib/libnativehelper.so:$(TARGET_COPY_OUT_VENDOR)/lib/hw/libnativehelper.so \
    vendor/meizu/m95/proprietary/vendor/lib64/libnativehelper.so:$(TARGET_COPY_OUT_VENDOR)/lib64/hw/libnativehelper.so

# Прошивка FM-DSP там, где её ищет НАШ драйвер ядра.
#
# FACT (kernel/m685, drivers/misc/mediatek/fmradio/mt6631/pub/mt6631_fm_lib.c:36-46):
# таблица патчей в нашем дереве ядра хранит АБСОЛЮТНЫЕ пути вида
# "/etc/firmware/mt6631/mt6631_fm_v1_patch.bin", и fm_file_exist/fm_file_read
# открывают их обычным filp_open (core/fm_patch.c:34,69) в контексте процесса,
# который дёрнул FM_IOCTL_POWERUP. На Android /etc — симлинк на /system/etc
# (out/target/product/m95/root/etc), поэтому файлы должны лежать в
# /system/etc/firmware/mt6631/.
#
# Блобы же лежат в /vendor/firmware/mt6631_fm_v1_{patch,coeff}.bin (так их
# кладёт и сток, и m95-vendor.mk:373-374). Стоковое ядро с ними работает
# потому, что ЕГО версия драйвера хранит голые имена ("mt6631_fm_v1_patch.bin",
# видно в строках распакованного stock/boot.img) и грузит их через
# request_firmware, а ueventd ищет в том числе /vendor/firmware. Наше дерево
# ядра старее и такой ветки не имеет.
#
# Из двух починок (переписать пути в ядре на /vendor/firmware либо положить
# файлы туда, куда смотрит драйвер) выбрана вторая: читает файл ДОМЕН
# ПРИЛОЖЕНИЯ (platform_app), а coredomain по
# system/sepolicy/public/domain.te:991-1009 (full_treble_only) не имеет права
# на vendor_file_type — исключение сделано ровно для домена kernel, то есть для
# request_firmware. Чтение /system/etc приложению разрешено штатно
# (public/app.te:90-95). При переходе в enforcing этот выбор ничего не ломает.
#
# INFERENCE: на 16.0 этот дефект не проявлялся, потому что до скачивания патча
# там ни разу не дошли — приложение не включает питание FM без наушников
# ("handlePowerUp, earphone is not ready"), а замер 2026-08-14 закончился
# на «драйвер отвечает».
PRODUCT_COPY_FILES += \
    vendor/meizu/m95/proprietary/vendor/firmware/mt6631_fm_v1_patch.bin:$(TARGET_COPY_OUT_SYSTEM)/etc/firmware/mt6631/mt6631_fm_v1_patch.bin \
    vendor/meizu/m95/proprietary/vendor/firmware/mt6631_fm_v1_coeff.bin:$(TARGET_COPY_OUT_SYSTEM)/etc/firmware/mt6631/mt6631_fm_v1_coeff.bin

# Таблица PLMN -> имя сети для RIL_REQUEST_OPERATOR.
#
# FACT (сборка 16, 2026-09-24): N-блоб mtk-ril.so отдаёт вместо имён числовой
# код ("OPERATOR {25002, 25002, 25002}") — модем он спрашивает только в
# числовом формате (AT+COPS=3,2 / AT+EOPS=3,2), а имена берёт лишь из NITZ.
# На стоке цифры заменял фреймворк MediaTek по /system/etc/spn-conf.xml; в
# Android 13 такой таблицы нет. Теперь имя подставляет наш libril
# (hardware/ril meizu-legacy-vendor, «give OPERATOR real names»), читая ту же
# стоковую таблицу из /vendor/etc (rild — вендорный домен; vendor_configs_file
# читают все домены, system/sepolicy/public/domain.te:209-210). Файл —
# стоковый /system/etc/spn-conf.xml побайтно, md5 0abd67a9…; в инвентаре
# device/meizu/m95/proprietary-files.txt он в перечне файлов вне основного списка.
PRODUCT_COPY_FILES += \
    vendor/meizu/m95/proprietary/vendor/etc/spn-conf.xml:$(TARGET_COPY_OUT_VENDOR)/etc/spn-conf.xml
