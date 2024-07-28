# CLibmagic

![Swift5.8+](https://img.shields.io/badge/Swift-5.8%2B-orange.svg?style=flat)
![platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20Linux-orange.svg?style=flat)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/0xfeedface1993/CLibmagic/blob/master/LICENSE)  

CLibmagic is a Swift library that provides a high-level interface to the `libmagic` library's C API for file type detection. It allows you to determine the MIME type and other information about files based on their content, not relying solely on file extensions.

## Features

- Swift wrapper around `libmagic` C API.
- Determine the MIME type and other information about files.
- Easy-to-use interface for file type detection.
- Cross-platform compatibility.
- Inspired by ❤️❤️ [swift-magic](https://github.com/kishikawakatsumi/swift-magic) ❤️❤️.

## Installation

You can include CLibmagic in your Swift project using the Swift Package Manager (SPM).

### Xcode project (macOS)

1. Open your Xcode project.
2. Select `File` > `Swift Packages` > `Add Package Dependency`.
3. Enter the URL of this repository: `https://github.com/0xfeedface1993/CLibmagic.git`.
4. Follow the prompts to complete the installation.

### Swift Package Manager (macOS, Linux)

add it to your package's dependencies:

```swift
.package(url: "https://github.com/0xfeedface1993/CLibmagic.git", from: "0.2.0")
```

## Usage

```swift
import CLibmagic

do {
    let fileURL = URL(fileURLWithPath: "/path/to/your/file")
    let mimeType = try CLibmagic.file(filePath, flags: .mime)
    print("MIME Type: \(mimeType)")
} catch {
    print("Error: \(error)")
}
```

The `file` function takes a URL to the file you want to detect and a set of `Flags` to control the behavior of the detection. The returned string will contain information about the detected file type.

## magic.mgc

File `Sources/MagicWrapper/Resources/Rules/magic.mgc` come from [file](https://github.com/0xfeedface1993/file.git), you can compile custom mgc file replace default file using those command

The `magic.mgc` file is sourced from the [file](https://github.com/0xfeedface1993/file.git) repository and is located at `Sources/MagicWrapper/Resources/Rules/magic.mgc`. You have the option to compile a custom `.mgc ` file and replace the default file using the following command:

```shell
file -m path/to/file/magic/Magdir -C
```

By executing the above command, you can generate your own `magic.mgc` file and replace the existing one with your custom compiled version.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, feel free to create a pull request.

## License

CLibmagic is released under the MIT License. See the [LICENSE](LICENSE) file for details.
