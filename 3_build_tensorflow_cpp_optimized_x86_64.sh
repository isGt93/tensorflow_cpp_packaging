#!/bin/bash

# Get the directory where the script is stored
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ ! -d $DIR/tensorflow ]; then
  echo Clone the appropriate tensorflow branch or tag with 1_clone_tensorflow.sh script
  exit 1
fi

#
# Generate the binaries
#
# Clean old packaging files if they exist
mkdir -p $DIR/packaging/libs
rm -rf $DIR/packaging/libs/*

cd $DIR/tensorflow
# Clean up
#git clean -fdx
#git reset --hard
#git apply < $DIR/tf_base.patch || exit 1
#git apply < $DIR/tf_optimized_x86_64.patch || exit 1

# Build the Tensorflow
cd tensorflow/contrib/cmake
#cmake . -Dtensorflow_ENABLE_GRPC_SUPPORT=OFF -Dtensorflow_ENABLE_SSL_SUPPORT=OFF -Dtensorflow_BUILD_PYTHON_BINDINGS=OFF \
#        -Dtensorflow_ENABLE_POSITION_INDEPENDENT_CODE=ON -Dtensorflow_BUILD_SHARED_LIB=ON -Dtensorflow_BUILD_CC_EXAMPLE=OFF -DCMAKE_BUILD_TYPE=Release || exit 1
make -j8 tensorflow || exit 1
cd ../../..

# Copy/prepare the final binaries
cp tensorflow/contrib/cmake/protobuf/src/protobuf/libprotobuf.a $DIR/packaging/libs/libprotobuf-tf-static.a || exit 1
g++ -shared -o $DIR/packaging/libs/libprotobuf-tf.so -Wl,--whole-archive -l:libprotobuf-tf-static.a -L$DIR/packaging/libs/ -Wl,--no-whole-archive || exit 1
cp tensorflow/contrib/cmake/nsync/src/nsync/libnsync.a $DIR/packaging/libs/libnsync-tf.a || exit 1
ar -x tensorflow/contrib/cmake/fft2d/src/fft2d/libfft2d.a
ar -r tensorflow/contrib/cmake/libtensorflow.a *.o  || exit 1
cp tensorflow/contrib/cmake/libtensorflow.a $DIR/packaging/libs/libtensorflow-core-static.a || exit 1
g++ -shared -o $DIR/packaging/libs/libtensorflow-core.so -Wl,--whole-archive -l:libtensorflow-core-static.a -L$DIR/packaging/libs/ -Wl,--no-whole-archive || exit 1
cp tensorflow/contrib/cmake/libtf_protos_cc.a $DIR/packaging/libs/libtf_protos_cc-static.a || exit 1
g++ -shared -o $DIR/packaging/libs/libtf_protos_cc.so -Wl,--whole-archive -l:libtf_protos_cc-static.a -L$DIR/packaging/libs/ -Wl,--no-whole-archive || exit 1

echo READY! Libraries are extracted to $DIR/packaging/libs/
