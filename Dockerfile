FROM ubuntu:18.04

ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK /opt/android-sdk-linux

ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/bin"

ENV DEBIAN_FRONTEND noninteractive

ADD /tools/android-wait-for-emulator.sh /opt

RUN mkdir /opt/android

# Install required tools
# Dependencies to execute Android builds

RUN dpkg --add-architecture i386 && apt-get update -yqq && apt-get install -y \
  curl \
  expect \
  git \
  libc6:i386 \
  libgcc1:i386 \
  libncurses5:i386 \
  libstdc++6:i386 \
  zlib1g:i386 \
  openjdk-8-jdk \
  wget \
  unzip \
  vim \
  && apt-get clean

RUN chmod a+x /opt/android-wait-for-emulator.sh

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

COPY tools /opt/tools

COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/tools/bin/sdkmanager "build-tools;29.0.3"

RUN /opt/android-sdk-linux/tools/bin/sdkmanager "platforms;android-28"

RUN /opt/android-sdk-linux/tools/bin/sdkmanager "platform-tools"

RUN /opt/android-sdk-linux/tools/bin/sdkmanager "emulator"

RUN /opt/android-sdk-linux/tools/bin/sdkmanager "system-images;android-28;default;x86"

RUN echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager --update

RUN echo "no" | avdmanager create avd -n first_avd --abi default/x86 -k "system-images;android-28;default;x86"

RUN echo "no" | avdmanager create avd -n second_avd --abi default/x86 -k "system-images;android-28;default;x86"

CMD /opt/tools/entrypoint.sh built-in
