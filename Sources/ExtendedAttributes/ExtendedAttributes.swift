//
//  ExtendedAttributes.swift
//  ExtendedAttributes
//
//  Created by Amir Abbas Mousavian.
//  Copyright © 2018 Mousavian. Distributed under MIT license.
//
//  Adopted from https://stackoverflow.com/a/38343753/5304286

import Foundation

public extension URL {
    /// Checks extended attribute has value
    public func hasExtendedAttribute(forName name: String) -> Bool {
        guard isFileURL else {
            return false
        }
        
        return self.withUnsafeFileSystemRepresentation { fileSystemPath -> Bool in
            return getxattr(fileSystemPath, name, nil, 0, 0, 0) > 0
        }
    }
    
    /// Get extended attribute.
    public func extendedAttribute(forName name: String) throws -> Data {
        try checkFileURL()
        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in
            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            
            // Create buffer with required size:
            var data = Data(count: length)
            
            // Retrieve attribute:
            if length > 0 {
                let result = data.withUnsafeMutableBytes {
                    getxattr(fileSystemPath, name, $0, length, 0, 0)
                }
                guard result >= 0 else { throw URL.posixError(errno) }
            }
            
            return data
        }
        return data
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
    public func setExtendedAttribute(data: Data, forName name: String) throws {
        try checkFileURL()
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0, data.count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
        }
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
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = removexattr(fileSystemPath, name, 0)
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }
    
    /// Get list of all extended attributes.
    public func listExtendedAttributes() throws -> [String] {
        try checkFileURL()
        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            
            // Create buffer with required size:
            var data = Data(count: length)
            
            // Retrieve attribute list:
            let result = data.withUnsafeMutableBytes {
                listxattr(fileSystemPath, $0, length, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            
            // Extract attribute names:
            let list = data.split(separator: 0).compactMap {
                String(data: Data($0), encoding: .utf8)
            }
            return list
        }
        return list
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
