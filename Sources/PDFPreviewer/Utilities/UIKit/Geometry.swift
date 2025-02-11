//
//  Geometry.swift
//
//
//  Created by 孟超 on 2024/9/16.
//


import Foundation
import CoreGraphics
#if os(iOS)
import UIKit
#endif

//MARK: - CGPoint

extension CGPoint {
    
    /// Returns the absolute value of the current coordinate.
    var abs: Self {
        Self(x: Swift.abs(self.x), y: Swift.abs(self.y))
    }
    
    /// Make the point pixel-perfect with the desired scale.
    ///
    /// - Parameter scale: The scale factor in which the receiver to be pixel-perfect.
    /// - Returns: An adjusted point.
    func aligned(scale: CGFloat = 1) -> Self {
        Self(x: (self.x * scale).rounded() / scale,
             y: (self.y * scale).rounded() / scale)
    }
    
    /// Returns the result of vector addition with the given point.
    func offset(dx: CGFloat, dy: CGFloat) -> Self {
        .init(x: self.x + dx, y: self.y + dy)
    }
    /// Returns the result of offsetting the `x` component of the point.
    func offset(dx: CGFloat) -> Self {
        .init(x: self.x + dx, y: self.y)
    }
    /// Returns the result of offsetting the `y` component of the point.
    func offset(dy: CGFloat) -> Self {
        .init(x: self.x, y: self.y + dy)
    }
    
    /// Performs vector addition with the given points and returns the result.
    static func +(lhs: Self, rhs: Self) -> Self {
        return .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    /// Performs vector subtraction with the given points and returns the result.
    static func -(lhs: Self, rhs: Self) -> Self {
        return lhs + .init(x: -rhs.x, y: -rhs.y)
    }
    /// Performs scalar multiplication with the given scalar and point.
    ///
    /// - Parameter lhs: The scalar to multiply by.
    /// - Parameter rhs: The point to multiply.
    static func *(lhs: CGFloat, rhs: Self) -> Self {
        return .init(x: lhs * rhs.x, y: lhs * rhs.y)
    }
    
    /// Performs vector addition with the current point.
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    /// Performs vector subtraction with the current point.
    static func -=(lhs: inout Self, rhs: Self) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    /// Performs scalar multiplication with the current point.
    static func *=(lhs: inout Self, rhs: CGFloat) {
        lhs.y *= rhs
        lhs.x *= rhs
    }
    
    /// Returns the coordinate of a point reversed.
    prefix static func -(prefix: Self) -> Self {
        return Self.init(x: -prefix.x, y: -prefix.y)
    }
    
    /// Scales the current point by a given value.
    func scale(_ value: CGFloat) -> Self {
        .init(x: value * x, y: value * y)
    }
    
    /// Rescales the current point by a given value.
    func rescale(_ value: CGFloat) -> Self {
        self.scale(1/value)
    }
    
    /// Converts the current point's coordinates into a size.
    var size: CGSize {
        .init(width: self.x, height: self.y)
    }
    
    /// Test approximate equality with relative tolerance.
    func isAlmostEqual(to point: Self, tolerance: CGFloat = CGFloat.ulpOfOne.squareRoot()) -> Bool {
        self.x.isAlmostEqual(to: point.x, tolerance: tolerance) && self.y.isAlmostEqual(to: point.y, tolerance: tolerance)
    }
    
}

//MARK: - CGSize

extension CGSize {
    /// The standardized value of the current size.
    ///
    /// If any component of the current size is negative, it will be set to `0` after standardization.
    var standardized: CGSize {
        .init(width: max(0, self.width), height: max(0, self.height))
    }
    /// Standardizes the current size.
    ///
    /// If any component of the current size is negative, the corresponding component will be set to `0` after standardization.
    mutating func standardize() {
        self.width = max(0, self.width)
        self.height = max(0, self.height)
    }
    
    /// Returns a size obtained by performing operations on the width and height of the current size.
    func offset(dw: CGFloat, dh: CGFloat) -> Self {
        return .init(width: width + dw, height: height + dh)
    }
    
    /// Returns a new size obtained by scaling the current size.
    func scale(_ value: CGFloat) -> Self {
        .init(width: value * width, height: value * height)
    }
    
    /// Returns a new size obtained by rescaling the current size.
    func rescale(_ value: CGFloat) -> Self {
        self.scale(1/value)
    }
    
    /// Test approximate equality with relative tolerance.
    func isAlmostEqual(to size: Self, tolerance: CGFloat = CGFloat.ulpOfOne.squareRoot()) -> Bool {
        self.width.isAlmostEqual(to: size.width, tolerance: tolerance) &&  self.height.isAlmostEqual(to: size.height, tolerance: tolerance)
    }
    
    static func *(left: CGFloat, right: Self) -> Self {
        return CGSize(width: left * right.width, height: left * right.height)
    }
    
    /// Converts the width and height of the current size into a point.
    var point: CGPoint {
        .init(x: self.width, y: self.height)
    }
    
    var rotatedSize: CGSize {
        CGSize(width: height, height: width)
    }
}

//MARK: - CGRect

extension CGRect {
    
    var isNotValid: Bool {
        (self.isNull || self.isEmpty || self.isInfinite)
    }
    
    /// Offsets the origin (top-left point) of the current rectangle by a vector.
    func offset(dx: CGFloat, dy: CGFloat) -> Self {
        .init(origin: self.origin.offset(dx: dx, dy: dy), size: self.size)
    }
    /// Offsets the origin (top-left point) of the current rectangle by a vector.
    func offset(dx: CGFloat) -> Self {
        .init(origin: self.origin.offset(dx: dx, dy: 0), size: self.size)
    }
    /// Offsets the origin (top-left point) of the current rectangle by a vector.
    func offset(dy: CGFloat) -> Self {
        .init(origin: self.origin.offset(dx: 0, dy: dy), size: self.size)
    }
    
    /// Scales the current rectangle.
    ///
    /// - Parameter value: The scaling factor to apply.
    func scale(_ value: CGFloat) -> Self {
        return CGRect(origin: value * self.origin, size: value * self.size)
    }
    
    /// Rescales the current rectangle.
    ///
    /// - Parameter value: The value by which the resulting rectangle is scaled to obtain the original rectangle.
    func rescale(_ value: CGFloat) -> Self {
        return CGRect(origin: 1/value * self.origin, size: 1/value * self.size)
    }
    
    /// Returns the top-left point of the rectangle.
    var topLeading: CGPoint {
        self.origin
    }
    /// Returns the center point of the top side of the rectangle.
    var top: CGPoint {
        self.origin.offset(dx: 0.5 * self.width)
    }
    /// Returns the top-right point of the rectangle.
    var topTrailing: CGPoint {
        self.origin.offset(dx: self.width)
    }
    /// Returns the center point of the left side of the rectangle.
    var leading: CGPoint {
        self.origin.offset(dy: 0.5 * self.height)
    }
    /// Returns the center point of the rectangle.
    var center: CGPoint {
        self.origin.offset(dx: 0.5 * self.width, dy: 0.5 * self.height)
    }
    /// Returns the center point of the right side of the rectangle.
    var trailing: CGPoint {
        self.origin.offset(dx: self.width, dy: 0.5 * self.height)
    }
    /// Returns the bottom-left point of the rectangle.
    var bottomLeading: CGPoint {
        self.origin.offset(dy: self.height)
    }
    /// Returns the center point of the bottom side of the rectangle.
    var bottom: CGPoint {
        self.bottomLeading.offset(dx: 0.5 * self.width)
    }
    /// Returns the bottom-right point of the rectangle.
    var bottomTrailing: CGPoint {
        self.bottom.offset(dx: 0.5 * self.width)
    }
    
    /// Returns a new rectangle with padding added.
    ///
    /// - Parameter top: The padding added to the top of the rectangle.
    /// - Parameter bottom: The padding added to the bottom of the rectangle.
    /// - Parameter left: The padding added to the left of the rectangle.
    /// - Parameter right: The padding added to the right of the rectangle.
    func padding(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) -> Self {
        let newOrigin = origin.offset(dx: -left, dy: -top)
        return .init(origin: newOrigin, size: .init(width: self.width + left + right, height: self.height + bottom + top)).standardized
    }
    
    #if os(iOS)
    /// Returns a new rectangle with padding added.
    ///
    /// - Parameter insets: The padding added, using a `UIEdgeInsets` struct to represent.
    func padding(insets: UIEdgeInsets) -> Self {
        self.padding(top: insets.top, bottom: insets.bottom, left: insets.left, right: insets.right)
    }
    #endif
    
    /// Returns a new rectangle with insets applied.
    ///
    /// - Parameter top: The value to inset from the top of the rectangle.
    /// - Parameter bottom: The value to inset from the bottom of the rectangle.
    /// - Parameter left: The value to inset from the left of the rectangle.
    /// - Parameter right: The value to inset from the right of the rectangle.
    func inseting(top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat) -> Self {
        let newOrigin = origin.offset(dx: left, dy: top)
        return .init(origin: newOrigin, size: .init(width: self.width - left - right, height: self.height - bottom - top)).standardized
    }
    
    enum HalfAlignment {
        case topLeading
        case top
        case leading
        case center
    }
    
    /// Returns a new rectangle of `1/4` size with the specified left-top position type in the original rectangle.
    ///
    /// - Parameter type: The position type of the left-top corner of the new rectangle in the original rectangle. Specifying this parameter will correspond to the respective point in the original rectangle.
    func halfRect(_ type: HalfAlignment) -> Self {
        let size = CGSize(width: 0.5 * self.width, height: 0.5 * self.height)
        switch type {
            case .topLeading:
                return .init(origin: self.topLeading, size: size)
            case .top:
                return .init(origin: self.top, size: size)
            case .leading:
                return .init(origin: self.leading, size: size)
            case .center:
                return .init(origin: self.center, size: size)
        }
    }
    
    /// Test approximate equality with relative tolerance.
    func isAlmostEqual(to rect: Self, tolerance: CGFloat = CGFloat.ulpOfOne.squareRoot()) -> Bool {
        self.origin.isAlmostEqual(to: rect.origin, tolerance: tolerance) &&
        self.size.isAlmostEqual(to: rect.size, tolerance: tolerance)
    }
    
    var pixelAligned: CGRect {
#if os(macOS)
        NSIntegralRectWithOptions(self, .alignAllEdgesNearest)
#else
        self.integral // May be not aligned
#endif
    }
    
}

