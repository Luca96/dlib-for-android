# Dlib-for-Android
Compile and embed Dlib (and, optionally OpenCV) in your Android projects with ease.

## Prerequisites
From _AndroidStudio_ at `tool > SDK Manager > SDK Tools` install:
* __LLDB__
* __CMake__
* __NDK__.

## Usage
1. Clone the repo __recursively__ (to download _Dlib_).
2. Create an Android project with __c++11__ support.
3. Edit the `setup.sh` (_Linux user_) or `setup.ps1` (_Windows user_) script:
	- Replace `AndroidCmake` variable with the path to your __Android CMake__ excutable (is usually inside the android `sdk` folder).
	- Replace `NDK` variable with the path to your __Android NDK__ (_ndk-bundle_).
	- Replace `TOOLCHAIN` variable with the path to your __android.toolchain.cmake__.
	- Select the ABIs you want to support among: `armeabi-v7a`, `arm64-v8a`, `x86` and `x86_64`.
	- Edit the `MIN_SDK` value, the minimum supported is `16`.
	- Set the `PROJECT_PATH` variable according to your Android project path.
4. Launch the __script__ and wait until completion (_comment what you don't need!_). It will:
	- Compile _Dlib_ for multiple _ABI_,
	- Copy the Dlib headers and `libdlib.so` to your project,
	- Copy the `lib_opencv4.so` to your project.
5. Edit your `CMakeLists` like [this one](https://gist.github.com/Luca96/4e7d6a0d0271c7bd147aea7d8c3681d6).
6. Update your `build.gradle` (app) file in order to support __CMake__ [example](https://gist.github.com/Luca96/32a66ddb8beb78712606cb375ebd4e9d).
7. Build and Enjoy! 

A complete tutorial is available [here](https://medium.com/@luca_anzalone/setting-up-dlib-and-opencv-for-android-3efdbfcf9e7f).

## Examples	
On my github you can find [here](https://github.com/Luca96/android-face-landmarks), a complete Android application that uses Dlib and OpenCV 4.

## Prebuilt library

Inside the folder `prebuilt` you can find a set of  *ready-to-use* `libdlib.so`, compiled from **Dlib 19.16** source code. 

The `.so` are built for the ABIs:  `armeabi-v7a`, `arm64-v8a`, `x86` and `x86_64`; with a **16** as `min-sdk`.

## Troubleshooting
_For Windows users_: If the __PowerShell__ complains about the script you can try this:
```
1. Open the Windows PowerShell
2. Move to the script location
3. type and execute: powershell -ExecutionPolicy ByPass -File setup.ps1
```

## Warning
Bash script __NOT TESTED!!__
