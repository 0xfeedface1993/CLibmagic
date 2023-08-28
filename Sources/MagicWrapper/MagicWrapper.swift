//
//  File.swift
//  
//
//  Created by john on 2023/8/28.
//

import Foundation
import CLibmagic
import Logging

fileprivate let logger = Logger(label: "com.magic.wrapper")

public enum MagicError: Error {
    case notFound
    case unexpected
    case invalidFileSystemRepresentation(URL)
}

public final class MagicWrapper {
    private var magic: magic_t?
    
    public init() {
        guard let mgcFile = Bundle.module.url(forResource: "magic", withExtension: "mgc") else {
            fatalError("'magic.mgc' is not found in bundle")
        }
        let path: UnsafePointer<CChar>
        do {
            path = try fileSystemRepresentation(mgcFile)
        } catch {
            fatalError("mgc file read path failed at \(mgcFile)")
        }
        self.magic = magic_open(MAGIC_NONE)
        magic_load(magic, path)
    }
    
    deinit {
        if let magic = magic {
            magic_close(magic)
        }
    }
    
    public func file(_ path: URL) throws -> String {
        return try file(path, flags: .none)
    }
    
    public func file(_ path: URL, flags: Flags) throws -> String {
        magic_setflags(magic, flags.rawValue)
        
        guard FileManager().fileExists(atPath: path.path) else {
            throw MagicError.notFound
        }
        
        let filePath = try fileSystemRepresentation(path)
        logger.info("magic_file(\(String(describing: magic)), \(path))")
        guard let description = magic_file(magic, filePath) else {
            throw MagicError.unexpected
        }
        
        return String(cString: description)
    }
    
    func fileSystemRepresentation(_ url: URL) throws -> UnsafePointer<CChar> {
        let path = url.withUnsafeFileSystemRepresentation { $0 }
        guard let path = path else {
            throw MagicError.invalidFileSystemRepresentation(url)
        }
        return path
    }
    
    public struct Flags: OptionSet {
        public let rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        /// No flags
        public static let none = Flags(rawValue: MAGIC_NONE)
        /// Turn on debugging
        public static let debug = Flags(rawValue: MAGIC_DEBUG)
        /// Follow symlinks
        public static let symlink = Flags(rawValue: MAGIC_SYMLINK)
        /// Check inside compressed files
        public static let compress = Flags(rawValue: MAGIC_COMPRESS)
        /// Look at the contents of devices
        public static let devices = Flags(rawValue: MAGIC_DEVICES)
        /// Return the MIME type
        public static let mimeType = Flags(rawValue: MAGIC_MIME_TYPE)
        /// Restore access time on exit
        public static let preserveAtime = Flags(rawValue: MAGIC_PRESERVE_ATIME)
        /// Return the MIME encoding
        public static let mimeEncoding = Flags(rawValue: MAGIC_MIME_ENCODING)
        public static let mime: Flags = [mimeType, mimeEncoding]
        /// Return the Apple creator/type
        public static let apple = Flags(rawValue: MAGIC_APPLE)
        /// Return a /-separated list of extensions
        public static let `extension` = Flags(rawValue: MAGIC_EXTENSION)
        /// Check inside compressed files but not report compression
        public static let compressTransp = Flags(rawValue: MAGIC_COMPRESS_TRANSP)
        public static let nodesc: Flags = [`extension`, mime, apple]
    }
}
