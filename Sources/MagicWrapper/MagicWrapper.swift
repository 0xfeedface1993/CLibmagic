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
    case invalidDataBaseAddress
}

public struct MagicInternalError: Error {
    public let code: Int32
    public let description: String
}

public final class MagicWrapper {
    private var magic: magic_t?
    
    public init(_ url: URL? = nil) {
        guard let mgcFile = url ?? Bundle.module.url(forResource: "magic", withExtension: "mgc") else {
            fatalError("'magic.mgc' is not found in bundle")
        }
        
        do {
            try mgcFile.withUnsafeFileSystemRepresentation {
                guard let pointer = $0 else {
                    throw MagicError.invalidFileSystemRepresentation(mgcFile)
                }
                self.magic = magic_open(MAGIC_NONE)
                magic_load(magic, pointer)
            }
        } catch {
            fatalError("mgc file read path failed at \(mgcFile)")
        }
        
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
        
        guard FileManager.default.fileExists(atPath: path.path) else {
            throw MagicError.notFound
        }
        
        return try path.withUnsafeFileSystemRepresentation {
            guard let pointer = $0 else {
                throw MagicError.invalidFileSystemRepresentation(path)
            }
            logger.info("magic_file(\(String(describing: magic)), \(path))")
            guard let description = magic_file(magic, pointer) else {
                throw error()
            }
            
            return String(cString: description)
        }
    }
    
    public func file(_ data: Data, flags: Flags) throws -> String {
        magic_setflags(magic, flags.rawValue)
        
        return try data.withUnsafeBytes {
            guard let pointer = $0.baseAddress else {
                throw MagicError.invalidDataBaseAddress
            }
            logger.info("magic_buffer(\(String(describing: magic)), \(data))")
            guard let description = magic_buffer(magic, pointer, data.count) else {
                throw error()
            }
            return String(cString: description)
        }
    }
    
    func error() -> Error {
        let code = magic_errno(magic)
        if let failure = magic_error(magic) {
            let string = String(cString: failure)
            return MagicInternalError(code: code, description: string)
        }
        return MagicInternalError(code: code, description: "unexpected")
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
