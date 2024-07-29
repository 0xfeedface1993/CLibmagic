// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let coreSources = [
    "libmagic/src/apptype.c",
    "libmagic/src/ascmagic.c",
    "libmagic/src/apprentice.c",
    "libmagic/src/buffer.c",
    "libmagic/src/compress.c",
    "libmagic/src/der.c",
    "libmagic/src/encoding.c",
    "libmagic/src/is_csv.c",
    "libmagic/src/is_json.c",
    "libmagic/src/is_simh.c",
    "libmagic/src/is_tar.c",
    "libmagic/src/magic.c",
    "libmagic/src/readelf.c",
    "libmagic/src/softmagic.c",
    "libmagic/src/cdf_time.c",
    "libmagic/src/cdf.c",
    "libmagic/src/readcdf.c",
    "libmagic/src/funcs.c",
    "libmagic/src/fsmagic.c",
    "libmagic/src/vasprintf.c",
    "libmagic/src/asprintf.c",
    "libmagic/src/print.c",
    "libmagic/src/dprintf.c",
]

#if os(Linux)
let sources = [
    "libmagic/src/strlcpy.c",
    "libmagic/src/fmtcheck.c",
]
#else
let sources = [String]()
#endif

let package = Package(
    name: "CLibmagic",
    platforms: [
        .macOS(.v10_15)
    ], 
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CLibmagic",
            targets: ["CLibmagic"]),
        .library(name: "MagicWrapper", targets: ["MagicWrapper"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CLibmagic",
            exclude: [
            ],
            sources: sources + coreSources,
            publicHeadersPath: "header",
            cSettings: [
                .headerSearchPath("header"),
                .define("HAVE_INTTYPES_H", .when(platforms: [.macOS, .linux])),
                .define("HAVE_STDINT_H", .when(platforms: [.macOS, .linux])),
                .define("HAVE_UNISTD_H", .when(platforms: [.macOS, .linux])),
            ],
            linkerSettings: [
                
            ],
            plugins: [
                .plugin(name: "GenerateMagicHPlugin")
            ]
        ),
        .target(
            name: "MagicWrapper",
            dependencies: [
                "CLibmagic",
                .product(name: "Logging", package: "swift-log"),
            ],
            resources: [.process("Resources/Rules")]
        ),
        .testTarget(
            name: "MagicWrapperTests",
            dependencies: ["MagicWrapper"],
            resources: [.process("Resources")]
        ),
        .plugin(
            name: "GenerateMagicHPlugin",
            capability: .buildTool(),
            path: "Sources/Plugins"
        ),
    ],
    cLanguageStandard: .gnu11
)
