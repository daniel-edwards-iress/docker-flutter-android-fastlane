ARG ubuntu_tag=22.04
FROM ubuntu:${ubuntu_tag}

RUN apt-get update && apt-get install -y ruby ruby-dev gcc make g++ bundler

ARG FLUTTER_VERSION=3.13.7
RUN apt-get install -y curl xz-utils git && \
  curl -o /tmp/flutter.tar.xz -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
  tar xf /tmp/flutter.tar.xz -C /usr/local && \
  rm -rf /tmp/flutter.tar.xz && \
  git config --global --add safe.directory /usr/local/flutter && \
  /usr/local/flutter/bin/flutter precache

ARG ANDROID_STUDIO_VERSION=10406996
ARG ANDROID_PLATFORM=34
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0
RUN apt-get install -y openjdk-17-jdk-headless && \
  curl -o /tmp/android-cli-tools.zip -L https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_STUDIO_VERSION}_latest.zip && \
  unzip -d /tmp /tmp/android-cli-tools.zip && \
  mkdir -p /usr/local/android-sdk/cmdline-tools && \
  mv /tmp/cmdline-tools /usr/local/android-sdk/cmdline-tools/latest && \
  rm -rf /tmp/android-cli-tools.zip && \
  yes | /usr/local/android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses && \
  yes | /usr/local/android-sdk/cmdline-tools/latest/bin/sdkmanager platform-tools "platforms;android-${ANDROID_PLATFORM}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"
RUN /usr/local/android-sdk/cmdline-tools/latest/bin/sdkmanager 'system-images;android-34;default;x86_64'
RUN /usr/local/android-sdk/cmdline-tools/latest/bin/avdmanager create avd -n test -k 'system-images;android-34;default;x86_64' -d 30
RUN /usr/local/android-sdk/cmdline-tools/latest/bin/sdkmanager 'emulator'
RUN apt-get install -y libgl1


ENV ANDROID_HOME=/usr/local/android-sdk
ENV PATH=$PATH:/usr/local/flutter/bin:/usr/local/android-sdk/cmdline-tools/latest/bin:/usr/local/android-sdk/emulator
