//
//  ExtendedAttributes.swift
//  ExtendedAttributes
//
//  Created by Amir Abbas Mousavian.
//  Copyright © 2018 Mousavian. Distributed under MIT license.
//
//  Adopted from https://stackoverflow.com/a/38343753/5304286

import Foundation

extension URL {
    /// Checks extended attribute has value
    public func hasExtendedAttribute(forName name: String) -> Bool {
        guard isFileURL else {
            return false
        }
        
        return withUnsafeFileSystemRepresentation { fileSystemPath -> Bool in
            getxattr(fileSystemPath, name, nil, 0, 0, 0) > 0
        }
    }
    
    /// Get extended attribute.
    public func extendedAttribute(forName name: String) throws -> Data {
        try checkFileURL()
        return try withUnsafeFileSystemRepresentation { fileSystemPath -> Data in
            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            
            // Create buffer with required size:
            var data = Data(count: length)
            
            // Retrieve attribute:
            if length > 0 {
                let result = getxattr(fileSystemPath, name, &data, length, 0, 0)
                guard result >= 0 else { throw URL.posixError(errno) }
            }
            
            return data
        }
    }
    
    /// Value of extended attribute.
    public func extendedAttributeValue<T>(forName name: String) throws -> T {
        try checkFileURL()
        let data = try extendedAttribute(forName: name)
        let value = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        guard let result = value as? T else {
            throw CocoaError(.propertyListReadCorrupt)
        }
        return result
    }
    
    /// Set extended attribute.
    public func setExtendedAttribute<DataType: DataProtocol>(data: DataType, forName name: String) throws {
        try checkFileURL()
        var data = Data(data)
        let result = withUnsafeFileSystemRepresentation { fileSystemPath in
            setxattr(fileSystemPath, name, &data, data.count, 0, 0)
        }
        guard result >= 0 else { throw URL.posixError(errno) }
    }
    
    /// Set extended attribute.
    public func setExtendedAttribute<T>(value: T, forName name: String) throws {
        try checkFileURL()
        
        // In some cases, like when value contains nil, PropertyListSerialization would crash.
        guard PropertyListSerialization.propertyList(value, isValidFor: .binary) else {
            throw CocoaError(.propertyListWriteInvalid)
        }
        
        let data = try PropertyListSerialization.data(fromPropertyList: value, format: .binary, options:0)
        try setExtendedAttribute(data: data, forName: name)
    }
    
    /// Remove extended attribute.
    public func removeExtendedAttribute(forName name: String) throws {
        try checkFileURL()
        let result = withUnsafeFileSystemRepresentation { fileSystemPath in
            removexattr(fileSystemPath, name, 0)
        }
        guard result >= 0 else { throw URL.posixError(errno) }
    }
    
    /// Get list of all extended attributes.
    public func listExtendedAttributes() throws -> [String] {
        try checkFileURL()
        return try withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            
            // Create buffer with required size:
            var buffer = [Int8](repeating: 0, count: length)
            
            // Retrieve attribute list:
            let result = listxattr(fileSystemPath, &buffer, length, 0)
            guard result >= 0 else { throw URL.posixError(errno) }
            
            // Extract attribute names:
            let list = buffer.map(UInt8.init(bitPattern:)).split(separator: 0).compactMap {
                String(decoding: $0, as: UTF8.self)
            }
            return list
        }
    }
    
    /// Helper function to create an NSError from a Unix errno.
    private static func posixError(_ err: Int32) -> POSIXError {
        return POSIXError(POSIXErrorCode(rawValue: err) ?? .EPERM)
    }
    
    private func checkFileURL() throws {
        guard isFileURL else {
            throw CocoaError(.fileNoSuchFile)
        }
    }
}
