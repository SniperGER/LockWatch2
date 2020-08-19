#!/bin/bash

function print_usage {
	echo -e "\
LockWatch Installer for iPadOS\n\
Version 1.0 © 2020 Team FESTIVAL\n\
\n\
Usage: $0 -b build_id -i device_address\n\
Example: $0 -b 17E262 -i iPad-pro.local\n\
\n\
  -V  iOS Version OR
  -b  iOS Build Number (13.4.1 => 17E262, see \x1B[4mhttps://www.theiphonewiki.com/wiki/Firmware/iPhone/13.x#iPhone_X\x1B[0m for more information)\n\
  -i  Device IP/hostname\n\
  -h  Print this help text"
}

while getopts "V:b:i:h" opt; do
  case $opt in
    V) BUILD_VERSION="$OPTARG"
	;;
    b) BUILD_ID="$OPTARG"
	;;
	i) DEVICE_IP="$OPTARG"
	;;
  	h)
	print_usage
	exit 0
	;;
  esac
done

if [[ (! -n $BUILD_VERSION && ! -n $BUILD_ID) || ! -n $DEVICE_IP ]]; then
	echo -e "Insufficient arguments\n"
	print_usage
	exit 1
fi

TEMPDIR=$(mktemp -d)

if [[ -n $BUILD_ID ]]; then
	echo "Checking iPhone10,6 IPSWs for build ${BUILD_ID}...";
	
	IPSW_INFO=$(curl -s "https://api.ipsw.me/v4/ipsw/iPhone10,6/${BUILD_ID}")
	
	if [[ ${#IPSW_INFO} -eq 0 ]]; then
		echo "Could not find IPSW for build ${BUILD_ID}, aborting."
		exit 1
	fi
	
	DOWNLOAD_URL=$(echo ${IPSW_INFO} | ruby -rjson -e 'data = JSON.parse(STDIN.read); puts data["url"]')

	if [[ ${#DOWNLOAD_URL} -eq 0 ]]; then
		echo "Could not find download URL for IPSW, aborting."
		exit 1
	fi
elif [[ -n $BUILD_VERSION ]]; then
	echo "Checking iPhone10,6 IPSWs for iOS ${BUILD_VERSION}...";
	
	DEVICE_INFO=$(curl -s "https://api.ipsw.me/v4/device/iPhone10,6?type=ipsw")
	
	if [[ ${#DEVICE_INFO} -eq 0 ]]; then
		echo "Could not find device iPhone10,6, aborting."
		exit 1
	fi
	
	DOWNLOAD_URL=$(echo ${DEVICE_INFO} | ruby -rjson -e "data = JSON.parse(STDIN.read); data['firmwares'].each do |firmware| if (firmware['version'] == '${BUILD_VERSION}') then puts firmware['url']; end; end")

	if [[ ${#DOWNLOAD_URL} -eq 0 ]]; then
		echo "Could not find download URL for IPSW, aborting."
		exit 1
	fi
fi

echo "Downloading firmware..."
curl -o ${TEMPDIR}/firmware.ipsw ${DOWNLOAD_URL}

echo "Extracting Restore.plist..."
unzip -p "${TEMPDIR}/firmware.ipsw" "Restore.plist" > "${TEMPDIR}/Restore.plist"

echo "Extracting root filesystem. This may take a while."
RESTORE_IMAGE=$(/usr/libexec/PlistBuddy "${TEMPDIR}/Restore.plist" -c "Print :SystemRestoreImageFileSystems" | grep = | sed 's/^\(.*\) =.*/\1/g' | awk '{print $1}')
unzip -p "${TEMPDIR}/firmware.ipsw" "${RESTORE_IMAGE}" > "${TEMPDIR}/${RESTORE_IMAGE}"

echo "Mounting root filesystem..."
VOLUME_PATH=$(hdiutil attach -noverify "${TEMPDIR}/${RESTORE_IMAGE}" | grep Volumes | sed -E 's/^.*(\/Volumes\/.*)/\1/' | awk '{print $1}')

echo "Extracting required files to intermediate directory..."
mkdir -p "${TEMPDIR}/copy"
FILELIST=(
	"/System/Library/LocationBundles/AppleWatchFaces.bundle/"
	"/System/Library/NanoTimeKit/ComplicationBundles/"
	"/System/Library/NanoPreferenceBundles/Customization/"
	"/System/Library/PrivateFrameworks/NanoTimeKitCompanion.framework/"	# Folder exists on iPadOS
	"/System/Library/PrivateFrameworks/NanoUniverse.framework/"			# Folder exists on iPadOS
	"/System/Library/PrivateFrameworks/NanoWeatherComplicationsCompanion.framework/"
)

for FILE in ${FILELIST[@]}; do
	mkdir -p "${TEMPDIR}/copy/${FILE}"
	rsync -r "${VOLUME_PATH}${FILE}" "${TEMPDIR}/copy${FILE}" --exclude .DS_Store --exclude ._*
done

echo "This step will copy the files to your device, which is potentially dangerous."
read -e -p "Are you sure you want to continue? [y/N] " CONFIRM
if [[ $CONFIRM == [Yy]* ]]; then
	echo "Copying extracted files to device..."
	find . -name ".DS_Store" -delete
	scp -q -r $TEMPDIR/copy/* root@$DEVICE_IP:/ > /dev/null 2>&1
else
	echo "Then why'd you put me through all this?"
fi

echo "Cleaning up..."
diskutil unmount $VOLUME_PATH
rm -rf "${TEMPDIR}"