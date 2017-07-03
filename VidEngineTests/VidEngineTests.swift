//
//  VidEngineTests.swift
//
//  Created by David Gavilan on 3/31/16.
//  Copyright © 2016 David Gavilan. All rights reserved.
//

import XCTest
import simd
@testable import VidEngine

class VidEngineTests: XCTestCase {
    let epsilon : Float = 0.0001

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testVector2() {
        var v = float2(0, 3)
        XCTAssertEqual(0, v.x)
        XCTAssertEqual(3, v.y)
        XCTAssertEqual(4 * 2, MemoryLayout<float2>.size)
        let unsafe = UnsafeMutablePointer<Float>.allocate(capacity: 2)
        memcpy(unsafe, &v, MemoryLayout<float2>.size)
        XCTAssertEqual(0, unsafe[0])
        XCTAssertEqual(3, unsafe[1])
        unsafe.deallocate(capacity: 2)
    }
    
    func testSpherical() {
        let sph = Spherical(v: float3(0,1,0))
        XCTAssertEqual(sph.r, 1)
        XCTAssertEqual(sph.θ, 0)
        XCTAssertEqual(sph.φ, 0)
    }
    
    func testSpectrum() {
        let spectrum = Spectrum(data: [400: 0.343, 404: 0.445, 408: 0.551, 412: 0.624])
        let m1 = spectrum.getIntensity(404)
        let m2 = spectrum.getIntensity(405)
        XCTAssertEqual(0.445, m1)
        XCTAssertEqual(0.471500009, m2)
    }
    
    func testXYZtoRGB() {
        // http://www.brucelindbloom.com
        // Model: sRGB, Gamma: 1.0
        let xyz = CieXYZ(xyz: float3(0.422683, 0.636309, 0.384312))
        let rgba = xyz.toRGBA()
        XCTAssertEqual(1, rgba.a)
        XCTAssertLessThanOrEqual(fabs(rgba.r - 0.2), epsilon)
        XCTAssertLessThanOrEqual(fabs(rgba.g - 0.8), epsilon)
        XCTAssertLessThanOrEqual(fabs(rgba.b - 0.3), epsilon)
    }
    
    func testCameraProjection() {
        let camera = Camera()
        camera.setPerspectiveProjection(fov: 90, near: 0.1, far: 100, aspectRatio: 1)
        camera.setViewDirection(float3(0,0,-1), up: float3(0,1,0))
        camera.setEyePosition(float3(0,2,20))
        XCTAssertLessThanOrEqual(distance(camera.projectionMatrix[0], float4(1,0,0,0)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.projectionMatrix[1], float4(0,1,0,0)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.projectionMatrix[2], float4(0,0,-1.002,-1.0)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.projectionMatrix[3], float4(0,0,-0.2002,0)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.inverseProjectionMatrix[0], float4(1,0,0,0)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.inverseProjectionMatrix[1], float4(0,1,0,0)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.inverseProjectionMatrix[2], float4(0,0,0,-4.995)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.inverseProjectionMatrix[3], float4(0,0,-1,5.005)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.transform.position, float3(0,2.0,20)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.transform.scale, float3(1.0,1.0,1.0)), epsilon)
        XCTAssertLessThanOrEqual(distance(camera.transform.rotation.q, float4(0,0,0,1)), epsilon)
        let worldPoint = float3(0.6, 1.2, -5)
        var viewPoint = camera.viewTransform * worldPoint
        // checked with Octave
        XCTAssertLessThanOrEqual(distance(viewPoint, float3(0.6, -0.8, -25.0)), epsilon)
        var worldPoint4 = float4(worldPoint.x, worldPoint.y, worldPoint.z, 1.0)
        var viewPoint4 = camera.viewTransformMatrix * worldPoint4
        XCTAssertLessThanOrEqual(distance(viewPoint4, float4(0.6, -0.8, -25.0, 1.0)), epsilon)
        let screenPoint = camera.projectionMatrix * viewPoint4
        XCTAssertLessThanOrEqual(distance(screenPoint, float4(0.6, -0.8, 24.84980, 25.0)), epsilon)
        var p = screenPoint * (1.0 / screenPoint.w)
        p = camera.inverseProjectionMatrix * p
        p = p * (1.0 / p.w)
        XCTAssertLessThanOrEqual(distance(viewPoint4, p), epsilon)
        var wp = camera.transform * float3(p.x, p.y, p.z)
        XCTAssertLessThanOrEqual(distance(worldPoint, wp), epsilon)
        let qx = Quaternion.createRotationAxis(.pi / 4, unitVector: float3(0,1,0))
        camera.rotation = qx
        viewPoint = camera.viewTransform * worldPoint
        XCTAssertLessThanOrEqual(distance(viewPoint, float3(18.1019, -0.8, -17.2534)), epsilon)
        worldPoint4 = float4(worldPoint.x, worldPoint.y, worldPoint.z, 1.0)
        viewPoint4 = camera.viewTransformMatrix * worldPoint4
        print(viewPoint4)
        XCTAssertLessThanOrEqual(distance(viewPoint4, float4(18.1019, -0.8, -17.2534, 1.0)), epsilon)
    }
    
    
}
