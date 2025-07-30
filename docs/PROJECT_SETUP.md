# Project setup

QuBitcoin Wallet is a cross-platform application, meaning it can be built for multiple target platforms using the same code base. It is important to note that some target platforms may only be accessible from specific host platforms. Below is a list of all supported host platforms and their corresponding target platforms:

| Host Platform | Target Platform                  |
| ------------- | -------------------------------- |
| macOS         | Web, macOS, iOS, iPadOS, Android |
| Windows       | Web, Windows, Android            |
| Linux         | Web, Linux, Android              |

## Host Platform Setup

 1. [Install Flutter, pin Flutter version](INSTALL_FLUTTER.md)
 2. Install IDEs
    - [VS Code](https://code.visualstudio.com/)
      - install and enable `Dart` and `Flutter` extensions
      - enable `Dart: Use recommended settings` via the Command Pallette
    - [Android Studio](https://developer.android.com/studio) - Ladybug | 2024.2.2
      - install and enable `Dart` and `Flutter` plugins
      - SDK Manager -> SDK Tools:
        - [x] Android SDK Build-Tools - (latest) 35.0.1
        - [x] NDK (Side by side) - (latest) 28.0
        - [x] Android command line tools - (latest) 19.0.0
        - [x] CMake - (latest) 3.31.5
    - [xCode](https://developer.apple.com/xcode/) | 16.2 (macOS only)
    - [Visual Studio](https://visualstudio.microsoft.com/vs/community/) | Community 17.13.0 (Windows only)
      - `Desktop development with C++` workload required
      - [Nuget CLI](https://www.nuget.org/downloads) required for Windows desktop builds
      - [Enable long paths in Windows registry](BUILD_RUN_APP.md#windows-desktop)

 3. Run `flutter doctor` and make sure all checks (except version) pass
 4. [Clone project repository](CLONE_REPOSITORY.md)
 5. Build and run the App for each target platform:
    - [Web](BUILD_RUN_APP.md#web)
    - [Android mobile](BUILD_RUN_APP.md#android)
    - [iOS mobile](BUILD_RUN_APP.md#ios) (macOS host only)
    - [macOS desktop](BUILD_RUN_APP.md#macos-desktop) (macOS host only)
    - [Windows desktop](BUILD_RUN_APP.md#windows-desktop) (Windows host only)
    - [Linux desktop](BUILD_RUN_APP.md#linux-desktop) (Linux host only)
 6. [Build release version](BUILD_RELEASE.md)

## Dev Container setup (Web and Android builds only)

1. Install [Docker](https://www.docker.com/get-started) for your operating system.
      - Linux: Install [Docker for your distribution](https://docs.docker.com/install/#supported-platforms) and add your user to the group by using terminal to run: `sudo usermod -aG docker $USER`.
      - Windows/macOS: Install [Docker Desktop for Windows/macOS](https://www.docker.com/products/docker-desktop), and if you are using WSL in Windows, please ensure that the [WSL 2 back-end](https://aka.ms/vscode-remote/containers/docker-wsl2) is installed and configured.
2. Install [VS Code](https://code.visualstudio.com/)
      - install and enable `Dart` and `Flutter` extensions
      - enable `Dart: Use recommended settings` via the Command Pallette
3. Install the VSCode [Dev Container extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
4. Open the command palette (Ctrl+Shift+P) and run `Remote-Containers: Reopen in Container`

## Possible Issues

### GitHub API 403 rate limit exceeded

If you get a 403 error when trying to build or run your app, it is likely that you have hit the [GitHub API rate limit](https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting). You can either wait for some time or create and add a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to your environment variables.

NOTE: The name of the environment variable should be `GITHUB_API_PUBLIC_READONLY_TOKEN`.

```bash
export GITHUB_API_PUBLIC_READONLY_TOKEN=<TOKEN>
```

Example of the 403 error message (more likely after multiple repeated builds):

```bash
test@test komodo-wallet % flutter build web 

Expected to find fonts for (MaterialIcons, packages/komodo_ui_kit/Custom, packages/cupertino_icons/CupertinoIcons), but found (MaterialIcons, packages/komodo_ui_kit/Custom). This usually means you are referring to font families in an IconData class but not including them in the assets section of your pubspec.yaml, are missing the package that would include
them, or are missing "uses-material-design: true".
Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 13640 bytes (99.2% reduction). Tree-shaking can be disabled by providing the --no-tree-shake-icons flag when building your app.
Target web_release_bundle failed: Error: User-defined transformation of asset "/Users/test/Repos/komodo/komodo-wallet/app_build/build_config.json" failed.
Transformer process terminated with non-zero exit code: 1
Transformer package: komodo_wallet_build_transformer
Full command: /Users/test/fvm/versions/3.22.3/bin/cache/dart-sdk/bin/dart run komodo_wallet_build_transformer --input=/var/folders/p7/4z261zj174l1hw7q7q7pnc200000gn/T/flutter_tools.2WE4fK/build_config.json-transformOutput0.json --output=/var/folders/p7/4z261zj174l1hw7q7q7pnc200000gn/T/flutter_tools.2WE4fK/build_config.json-transformOutput1.json
--fetch_defi_api --fetch_coin_assets --copy_platform_assets --artifact_output_package=web_dex --config_output_path=app_build/build_config.json
stdout:
SHOUT: 2024-09-30 13:18:58.286118: Error running build steps
Exception: Failed to retrieve latest commit hash: master[403]: rate limit exceeded
#0      GithubApiProvider.getLatestCommitHash (package:komodo_wallet_build_transformer/src/steps/github/github_api_provider.dart:92:7)
<asynchronous suspension>
#1      FetchCoinAssetsBuildStep.canSkip (package:komodo_wallet_build_transformer/src/steps/fetch_coin_assets_build_step.dart:139:30)
<asynchronous suspension>
#2      _runStep (file:///Users/test/.pub-cache/git/komodo-defi-sdk-flutter-388f04296a5531c3cdad766269a3040d2b4ee9ac/packages/komodo_wallet_build_transformer/bin/komodo_wallet_build_transformer.dart:224:7)
<asynchronous suspension>
#3      main (file:///Users/test/.pub-cache/git/komodo-defi-sdk-flutter-388f04296a5531c3cdad766269a3040d2b4ee9ac/packages/komodo_wallet_build_transformer/bin/komodo_wallet_build_transformer.dart:189:9)
<asynchronous suspension>
```
