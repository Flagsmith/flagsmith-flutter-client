# Runs this SDK, built from source, under the Flagsmith SDK behavioural spec.
# docker build -f sdk-spec/Dockerfile --build-context harness=<sdk-spec>/harness/dart .
FROM ghcr.io/cirruslabs/flutter:3.44.0

WORKDIR /sdk
COPY . .
COPY --from=harness . /harness
RUN flutter pub get \
    && dart /harness/build.dart -o sdk-spec/harness_main.dart sdk-spec/steps.dart \
    && flutter build bundle --debug --target sdk-spec/harness_main.dart \
    && ln -s "$(find "$(dirname "$(readlink -f "$(command -v flutter)")")/cache/artifacts/engine" \
        -path '*/linux-*/flutter_tester' -print -quit)" /usr/local/bin/flutter_tester

# The SDK needs Flutter, so run on the headless engine that `flutter test` uses.
ENTRYPOINT ["flutter_tester", "--non-interactive", "--disable-vm-service", "build/flutter_assets/kernel_blob.bin"]
