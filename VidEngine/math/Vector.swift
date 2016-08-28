//
//  Vector.swift
//
//  Created by David Gavilan on 2/7/15.
//  Copyright (c) 2015 David Gavilan. All rights reserved.
//

import simd

public extension float3 {
    func inverse() -> float3 {
        return float3( x: fabsf(self.x)>0 ? 1/self.x : 0,
                       y: fabsf(self.y)>0 ? 1/self.y : 0,
                       z: fabsf(self.z)>0 ? 1/self.z : 0)
    }
    /// similar vectors
    func isClose(v: float3, epsilon: Float = 0.0001) -> Bool {
        let diff = self - v
        return IsClose(length_squared(diff), 0)
    }
}

// sizeof(float3) = 16!! sizeof(Vec3) = 12
struct Vec3 {
    let x : Float
    let y : Float
    let z : Float
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    init(_ v: float3) {
        self.x = v.x
        self.y = v.y
        self.z = v.z
    }
}

struct Vec2 {
    let x : Float
    let y : Float
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
}

func * (v: Vec3, f: Float) -> Vec3 {
    return Vec3(v.x * f, v.y * f, v.z * f)
}
func * (f: Float, v: Vec3) -> Vec3 {
    return v * f
}
