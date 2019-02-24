#!/bin/bash
# Luca Anzalone

# -----------------------------------------------------------------------------
# -- DLIB FOR ANDROID
# -----------------------------------------------------------------------------

# Android-cmake path: REPLACE WITH YOUR CMAKE PATH!
CMAKE_PATH='E:/Luca/Android/sdk/cmake/3.10.2.4988404/'
ANDROID_CMAKE="$CMAKE_PATH/bin/cmake"

# Android-ndk path: REPLACE WITH YOUR NDK PATH!
NDK="${ANDROID_NDK:-E:/Luca/Android/sdk/ndk-bundle}"

TOOLCHAIN="$CMAKE_PATH/bin/android.toolchain.cmake"

# Supported Android ABI: TAKE ONLY WHAT YOU NEED!
ABI=('armeabi-v7a' 'arm64-v8a' 'x86' 'x86_64')

# Minimum supported sdk: SHOULD BE GREATER THAN 16
MIN_SDK=16

# Android project path: REPLACE WITH YOUR PROJECT PATH!
PROJECT_PATH='E:/Luca/Progetti/Android/FaceLandmarks'

# -----------------------------------------------------------------------------
# -- Dlib setup
# ----------------------------------------------------------------------------- 

# Dlib library path: REPLACE WITH YOUR DLIB PATH!
DLIB_PATH='E:/Luca/Librerie/Dlib/dlib-19.16'

function compile_dlib {
	cd $DLIB_PATH
	mkdir 'build'

	for abi in "${ABI[@]}"
	do
		echo 
		echo "=> Compiling Dlib for ABI: '$abi'..."

		mkdir "build/$abi"
		cd "build/$abi"

		ANDROID_CMAKE -DBUILD_SHARED_LIBS=1 \
					  -DANDROID_NDK=$NDK \
					  -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN \
					  -DCMAKE_BUILD_TYPE=Release \
					  -DCMAKE_CXX_FLAGS=-std=c++11 -frtti -fexceptions \
					  -DCMAKE_C_FLAGS=-O3 \
					  -DANDROID_ABI=$abi \
					  -DANDROID_PLATFORM="android-$MIN_SDK" \
					  -DANDROID_TOOLCHAIN=clang \
					  -DANDROID_STL=c++_shared \
					  -DANDROID_CPP_FEATURES=rtti exceptions \
					  ../../
 		
 		echo "=> Generating the 'dlib/libdlib.so' for ABI: '$abi'..."
		ANDROID_CMAKE --build .

		echo '=> done.'
		cd ../../
	done
}

echo '=> Compiling Dlib...'
compile_dlib

# -----------------------------------------------------------------------------
# -- Project setup
# -----------------------------------------------------------------------------

cd "$PROJECT_PATH/app/src/main"
mkdir 'cppLibs'

# -----------------------------------------------------------------------------
# -- Dlib stuff
# -----------------------------------------------------------------------------
echo '=> Making directories for Dlib ...'
mkdir 'cppLibs/dlib'
echo "=> 'cppLibs/dlib' created."
mkdir 'cppLibs/dlib/lib'
echo "=> 'cppLibs/dlib/lib' created."
mkdir 'cppLibs/dlib/include'
echo "=> 'cppLibs/dlib/include' created."

echo "=> Copying Dlib headers..."
cp -v "$DLIB_PATH/dlib/" "$PROJECT_PATH/cppLibs/dlib/include"

echo "=> Copying 'libdlib.so' for each ABI..."
for abi in "${ABI[@]}"
do
	mkdir "cppLibs/dlib/lib/$abi"
	cp -v "$DLIB_PATH/build/$abi/dlib/libdlib.so" "cppLibs/dlib/lib/$abi"
done

# -----------------------------------------------------------------------------
# -- OpenCV stuff
# -----------------------------------------------------------------------------

# OpenCV library path: REPLACE WITH YOUR OPENCV PATH!
OPENCV_PATH='E:/Luca/Librerie/OpenCV/opencv-4.0.1-android-sdk/sdk/native'

mkdir 'cppLibs/opencv'

echo "=> Copying 'libopencv_java4.so' for each ABI..."
for abi in "${ABI[@]}"
do
	mkdir "cppLibs/opencv/$abi"
	cp -v "$OPENCV_PATH/libs/$abi/libopencv_java4.so" "cppLibs/opencv/$abi"
done

# -----------------------------------------------------------------------------

echo "=> Project configuration completed."

# -----------------------------------------------------------------------------