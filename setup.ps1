# Luca Anzalone

# -----------------------------------------------------------------------------
# -- DLIB FOR ANDROID
# -----------------------------------------------------------------------------

# Android-cmake path: REPLACE WITH YOUR CMAKE PATH!
$AndroidCmake = 'E:\Luca\Android\sdk\cmake\3.10.2.4988404\bin\cmake.exe'

# Android-ndk path: REPLACE WITH YOUR NDK PATH!
if (Get-Variable 'ANDROID_NDK' -Scope Global -ErrorAction 'Ignore') {
    $NDK = $ANDROID_NDK
} else {
    $NDK = 'E:\Luca\Android\sdk\ndk-bundle'
}

# Android toolchain path: REPLACE WITH YOUR ANDROID-TOOLCHAIN PATH!!
$TOOLCHAIN = 'E:\Luca\Android\sdk\ndk-bundle\build\cmake\android.toolchain.cmake'

# Supported Android ABI: TAKE ONLY WHAT YOU NEED!
$ABIs = 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'

# Minimum supported sdk: SHOULD BE GREATER THAN 16
$MIN_SDK = 16

# Android project path: REPLACE WITH YOUR PROJECT PATH!
$PROJECT_PATH = 'E:\Luca\Progetti\Android\FaceLandmarks'

# -----------------------------------------------------------------------------
# -- Utils
# -----------------------------------------------------------------------------
$INITIAL_LOCATION = Get-Location

function Make-Dir {
    if (-Not (Test-Path $args[0])) {
        New-Item -ItemType directory -Path $args[0] > $null
    }
}

function Copy-Directory ($from, $to, $tab) {
    $Items = Get-ChildItem $from
    
    ForEach ($item in $Items) {
        if ((Get-Item $item.FullName) -is [System.IO.DirectoryInfo]) {
            Write-Host "$tab > $item"
            Make-Dir "$to\$item"
            Copy-Directory "$from\$item" "$to\$item" "$tab  "
        } else {
            Copy-Item -Path $item.FullName -Destination $to
            Write-Host "$tab | $item copied." 
        }
    }
}

# -----------------------------------------------------------------------------
# -- Dlib setup
# ----------------------------------------------------------------------------- 

# Dlib library path: REPLACE WITH YOUR DLIB PATH!
$DLIB_PATH = 'E:\Luca\Librerie\Dlib\dlib-19.16'

function Compile-Dlib {
    Set-Location $DLIB_PATH
    Make-Dir 'build'

    ForEach ($abi in $ABIs) {
        Write-Host
        Write-Host "=> Compiling Dlib for ABI: '$abi'..."
        sleep 0.5

        Make-Dir "build\$abi"
        Set-Location "build\$abi"

        $cmakeArguments = @(
                "-DBUILD_SHARED_LIBS=1",
                "-DANDROID_NDK=$NDK",
                "-DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN",
                "-GNinja",
                "-DCMAKE_BUILD_TYPE=Release",
                "-DCMAKE_CXX_FLAGS=-std=c++11 -frtti -fexceptions",
                "-DCMAKE_C_FLAGS=-O3",
                "-DANDROID_ABI=$abi",
                "-DANDROID_PLATFORM=android-$MIN_SDK",
                "-DANDROID_TOOLCHAIN=clang",
                "-DANDROID_STL=c++_shared",
                "-DANDROID_CPP_FEATURES=rtti exceptions",
                "-DCMAKE_PREFIX_PATH=..\..\",
                "..\..\"
        )

        & $AndroidCmake $cmakeArguments
        sleep 0.5

        Write-Host "=> Generating the 'dlib/libdlib.so' for ABI: '$abi'..."
        & $AndroidCmake --build .
        sleep 0.5

        Write-Host '=> done.'
        Set-Location ..\..\
        sleep 0.5
    }    
}

Write-Host '=> Compiling Dlib...'
sleep 0.5
# Compile-Dlib

# -----------------------------------------------------------------------------
# -- Project setup
# -----------------------------------------------------------------------------

Set-Location "$PROJECT_PATH\app\src\main"
Make-Dir 'cppLibs'

# -----------------------------------------------------------------------------
# -- Dlib stuff
# -----------------------------------------------------------------------------
Write-Host '=> Making directories for Dlib ...'
Make-Dir 'cppLibs\dlib'
Write-Host "=> 'cppLibs\dlib' created."
Make-Dir 'cppLibs\dlib\lib'
Write-Host "=> 'cppLibs\dlib\lib' created."
Make-Dir 'cppLibs\dlib\include'
Write-Host "=> 'cppLibs\dlib\include' created."

Write-Host "=> Copying Dlib headers..."
# Copy-Item -Path "$DLIB_PATH\dlib" -Destination "$PROJECT_PATH\cppLibs\dlib\include" -Recurse
Copy-Directory "$DLIB_PATH\dlib" "cppLibs\dlib\include" ''

Write-Host "=> Copying 'libdlib.so' for each ABI..."
ForEach ($abi in $ABIs) {
    Make-Dir "cppLibs\dlib\lib\$abi"
    Copy-Item -Path "$DLIB_PATH\build\$abi\dlib\libdlib.so" -Destination "cppLibs\dlib\lib\$abi"
}

# -----------------------------------------------------------------------------
# -- OpenCV stuff
# -----------------------------------------------------------------------------

# OpenCV library path: REPLACE WITH YOUR OPENCV PATH!
$OPENCV_PATH='E:\Luca\Librerie\OpenCV\opencv-4.0.1-android-sdk\sdk\native'

Make-Dir 'cppLibs\opencv'

Write-Host "=> Copying 'libopencv_java4.so' for each ABI..."
ForEach ($abi in $ABIs) {
    Make-Dir "cppLibs\opencv\$abi"
    Copy-Item -Path "$OPENCV_PATH\libs\$abi\libopencv_java4.so" -Destination "cppLibs\opencv\$abi"
}

# -----------------------------------------------------------------------------

Set-Location $INITIAL_LOCATION
Write-Host "=> Project configuration completed."

# -----------------------------------------------------------------------------