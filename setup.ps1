# Luca Anzalone

# -----------------------------------------------------------------------------
# -- DLIB FOR ANDROID: setup script
# -----------------------------------------------------------------------------

# Android-cmake path: REPLACE WITH YOUR CMAKE PATH!
$AndroidCmake = 'your-path-to\Android\sdk\cmake\3.10.2.4988404\bin\cmake.exe'

# Android-ndk path: REPLACE WITH YOUR NDK PATH!
if (Get-Variable 'ANDROID_NDK' -Scope Global -ErrorAction 'Ignore') {
    $NDK = $ANDROID_NDK
} else {
    $NDK = 'your-path-to\Android\sdk\ndk-bundle'
}

$TOOLCHAIN = "$NDK\build\cmake\android.toolchain.cmake"

# Supported Android ABI: TAKE ONLY WHAT YOU NEED!
$ABIs = 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'

# path to stripper tool: REPLACE WITH YOURS, ACCORDING TO OS!!
$STRIPPER_PATH = "$NDK\toolchains\llvm\prebuilt\windows-x86_64\bin"
$STRIPPERS = @{
    'armeabi-v7a' = "$STRIPPER_PATH\arm-linux-androideabi-strip.exe";
    'arm64-v8a'   = "$STRIPPER_PATH\aarch64-linux-android-strip.exe";
    'x86'         = "$STRIPPER_PATH\x86_64-linux-android-strip.exe" ;
    'x86_64'      = "$STRIPPER_PATH\x86_64-linux-android-strip.exe" ;    
} 

# Minimum supported sdk: SHOULD BE GREATER THAN 16
$MIN_SDK = 16

# Android project path: REPLACE WITH YOUR PROJECT PATH!
$PROJECT_PATH = 'your-path-to\android\project'

# Directory for storing native libraries
$NATIVE_DIR = "$PROJECT_PATH\app\src\main\cppLibs"

# -----------------------------------------------------------------------------
# -- Utils
# -----------------------------------------------------------------------------
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
# -- Dlib
# ----------------------------------------------------------------------------- 

# Dlib library path:
$DLIB_PATH = 'dlib'

function Compile-Dlib {
    Set-Location $DLIB_PATH
    Make-Dir 'build'

    Write-Host '=> Compiling Dlib...'
    sleep 0.5

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

        $stripArguments = @(
                "--strip-unneeded",
                "dlib/libdlib.so"
        )

        & $AndroidCmake $cmakeArguments
        sleep 0.5

        Write-Host "=> Generating the 'dlib/libdlib.so' for ABI: '$abi'..."
        & $AndroidCmake --build .
        sleep 0.5

        Write-Host "=> Stripping libdlib.so for ABI: '$abi'to reduce space..."
        & $STRIPPERS[$abi] $stripArguments
        sleep 0.5

        Write-Host '=> done.'
        Set-Location ..\..\
        sleep 0.5
    }    
}

function Dlib-Setup {
    Write-Host '=> Making directories for Dlib...'
    Make-Dir "$NATIVE_DIR\dlib"
    Write-Host "=> '$NATIVE_DIR\dlib' created."
    Make-Dir "$NATIVE_DIR\dlib\lib"
    Write-Host "=> '$NATIVE_DIR\dlib\lib' created."
    Make-Dir "$NATIVE_DIR\dlib\include"
    Write-Host "=> '$NATIVE_DIR\dlib\include' created."
    Make-Dir "$NATIVE_DIR\dlib\include\dlib"
    Write-Host "=> '$NATIVE_DIR\dlib\include\dlib' created."

    Write-Host "=> Copying Dlib headers..."
    Copy-Directory "$DLIB_PATH\dlib" "$NATIVE_DIR\dlib\include\dlib" ''

    Write-Host "=> Copying 'libdlib.so' for each ABI..."
    ForEach ($abi in $ABIs) {
        Make-Dir "$NATIVE_DIR\dlib\lib\$abi"
        Copy-Item -Path "$DLIB_PATH\build\$abi\dlib\libdlib.so" -Destination "$NATIVE_DIR\dlib\lib\$abi"
        Write-Host " > Copied libdlib.so for $abi"
    }
}

# COMMENT TO DISABLE COMPILATION
Compile-Dlib

# -----------------------------------------------------------------------------
# -- OpenCV
# -----------------------------------------------------------------------------

# OpenCV library path: REPLACE WITH YOUR OPENCV PATH!
$OPENCV_PATH='path-to-your\opencv-4.0.1-android-sdk\sdk\native'

function Opencv-Setup {
    Make-Dir "$NATIVE_DIR\opencv"

    Write-Host "=> Copying 'libopencv_java4.so' for each ABI..."
    ForEach ($abi in $ABIs) {
        Make-Dir "$NATIVE_DIR\opencv\$abi"
        Copy-Item -Path "$OPENCV_PATH\libs\$abi\libopencv_java4.so" -Destination "$NATIVE_DIR\opencv\$abi"
        Write-Host " > Copied libopencv_java4.so for $abi"
    }
}

# -----------------------------------------------------------------------------
# -- Project setup
# -----------------------------------------------------------------------------

Make-Dir $NATIVE_DIR

# COMMENT TO NOT COPY DLIB '.so' FILES
Dlib-Setup

# COMMENT TO NOT COPY OPENCV '.so' FILES
Opencv-Setup

Write-Host "=> Project configuration completed."

# -----------------------------------------------------------------------------