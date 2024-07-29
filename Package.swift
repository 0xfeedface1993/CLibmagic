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
    "libmagic/src/print.c",
]

var missingSources: [String] = []

#if os(Linux)
#if !HAVE_STRLCPY
missingSources.append("libmagic/src/strlcpy.c")
#endif

#if !HAVE_STRLCAT
missingSources.append("libmagic/src/strlcat.c")
#endif

#if !HAVE_STRCASESTR
missingSources.append("libmagic/src/strcasestr.c")
#endif

#if !HAVE_GETLINE
missingSources.append("libmagic/src/getline.c")
#endif

#if !HAVE_CTIME_R
missingSources.append("libmagic/src/ctime_r.c")
#endif

#if !HAVE_ASCTIME_R
missingSources.append("libmagic/src/asctime_r.c")
#endif

#if !HAVE_GMTIME_R
missingSources.append("libmagic/src/gmtime_r.c")
#endif

#if !HAVE_LOCALTIME_R
missingSources.append("libmagic/src/localtime_r.c")
#endif

#if !HAVE_FMTCHECK
missingSources.append("libmagic/src/fmtcheck.c")
#endif

#if !HAVE_PREAD
missingSources.append("libmagic/src/pread.c")
#endif
#endif

#if !HAVE_VASPRINTF
missingSources.append("libmagic/src/vasprintf.c")
#endif

#if !HAVE_ASPRINTF
missingSources.append("libmagic/src/asprintf.c")
#endif

#if !HAVE_DPRINTF
missingSources.append("libmagic/src/dprintf.c")
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
            sources: missingSources + coreSources,
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
