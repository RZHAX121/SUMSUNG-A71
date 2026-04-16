#!/bin/bash

function _help(){
	echo "Usage: build.sh --device DEV"
	echo
	echo "Build edk2 for Qualcomm Snapdragon platforms (Modified for SUMSUNG-A71)."
	echo
	echo "Options: "
	echo "	--device DEV, -d DEV:    build for DEV (e.g., a71)."
	echo "	--release MODE, -r MODE: Release mode, 'RELEASE' (default) or 'DEBUG'."
	echo "	--toolchain TOOLCHAIN:   Set toolchain, default is 'GCC5'."
	echo "	--clean, -C:             clean workspace and output."
	echo "	--help, -h:              show this help."
	echo
	exit "${1}"
}

function _error(){ echo "${@}" >&2;exit 1; }

# الإعدادات الأساسية
OUTDIR="${PWD}"
ROOTDIR="$(realpath "$(dirname "$0")")"
cd "${ROOTDIR}"||exit 1
DEVICE=""
MODE=RELEASE
CLEAN=false
TOOLCHAIN=GCC5
export ROOTDIR OUTDIR

# قراءة الخيارات
OPTS="$(getopt -o d:r:t:hC -l device:,release:,toolchain:,help,clean -n 'build.sh' -- "$@")"||exit 1
eval set -- "${OPTS}"
while true
do	case "${1}" in
		-d|--device) DEVICE="${2}";shift 2;;
		-r|--release) MODE="${2}";shift 2;;
		-t|--toolchain) TOOLCHAIN="${2}";shift 2;;
		-C|--clean) CLEAN=true;shift;;
		-h|--help) _help 0;;
		--) shift;break;;
		*) _help 1;;
	esac
done

[ -z "${DEVICE}" ]&&_help 1

function _clean(){
	rm -rf "${OUTDIR}/workspace" "${OUTDIR}/Build/${DEVICE}"
	rm -f "${OUTDIR}/boot-${DEVICE}.img"
	echo "Cleaned."
}

if "${CLEAN}";then _clean;exit 0;fi

# تجهيز بيئة البناء
echo "=== إعداد بيئة البناء لـ ${DEVICE} ==="

# استنساخ edk2 إذا لم يكن موجوداً
if [ ! -d "edk2" ]; then
	echo "استنساخ edk2..."
	git clone --depth 1 https://github.com/tianocore/edk2.git
fi

# استنساخ edk2-platforms إذا لم يكن موجوداً
if [ ! -d "edk2-platforms" ]; then
	echo "استنساخ edk2-platforms..."
	git clone --depth 1 https://github.com/tianocore/edk2-platforms.git
fi

# نسخ ملفات المنصة إلى المكان الصحيح
echo "نسخ ملفات المنصة..."
cp -r Platform/* edk2-platforms/Platform/ 2>/dev/null || true
cp -r Silicon edk2-platforms/ 2>/dev/null || true

# إعداد المتغيرات
_EDK2="$(realpath edk2)"
_EDK2_PLATFORMS="$(realpath edk2-platforms)"
export GCC5_AARCH64_PREFIX="${CROSS_COMPILE:-aarch64-linux-gnu-}"
export PACKAGES_PATH="${_EDK2}:${_EDK2_PLATFORMS}:${ROOTDIR}"
export WORKSPACE="${OUTDIR}/workspace"
mkdir -p "${WORKSPACE}"

echo "EDK2 Path: ${_EDK2}"
echo "Platforms Path: ${_EDK2_PLATFORMS}"

# تحميل إعدادات الجهاز
if [ -f "configs/devices/${DEVICE}.conf" ]; then
	source "configs/devices/${DEVICE}.conf"
else
	echo "تحذير: ملف إعدادات ${DEVICE} غير موجود، استخدام الإعدادات الافتراضية"
	VENDOR_NAME="Samsung"
	SOC_PLATFORM="sm7150"
	PLATFORM_NAME="a71"
	FD_BASE="0xA0000000"
	FD_SIZE="0x00200000"
fi

# بناء BaseTools
echo "=== بناء BaseTools ==="
cd "${_EDK2}"
source edksetup.sh
make -C BaseTools || _error "فشل بناء BaseTools"
cd "${ROOTDIR}"

# بناء UEFI
echo "=== بناء UEFI لـ ${DEVICE} ==="
case "${MODE}" in
	RELEASE) _MODE=RELEASE;;
	*) _MODE=DEBUG;;
esac

build \
	-a AARCH64 \
	-t "${TOOLCHAIN}" \
	-p "edk2-platforms/Platform/${VENDOR_NAME}/${SOC_PLATFORM}/${PLATFORM_NAME}.dsc" \
	-b "${_MODE}" \
	-D FIRMWARE_VER="1.0" \
	-D FD_BASE="${FD_BASE}" -D FD_SIZE="${FD_SIZE}" \
	|| _error "فشل بناء UEFI"

# نسخ الملف الناتج
BUILD_DIR="${WORKSPACE}/Build/${PLATFORM_NAME}/${_MODE}_${TOOLCHAIN}/FV"
if [ -f "${BUILD_DIR}/${SOC_PLATFORM^^}_UEFI.fd" ]; then
	cp "${BUILD_DIR}/${SOC_PLATFORM^^}_UEFI.fd" "${OUTDIR}/boot-${DEVICE}.img"
	echo "✅ تم البناء بنجاح!"
	echo "📁 الملف الناتج: ${OUTDIR}/boot-${DEVICE}.img"
else
	_error "❌ الملف الناتج غير موجود"
fi