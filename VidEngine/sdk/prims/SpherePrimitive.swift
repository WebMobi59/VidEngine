//
//  SpherePrimitive.swift
//  VidEngine
//
//  Created by David Gavilan on 8/28/16.
//  Copyright © 2016 David Gavilan. All rights reserved.
//

import Metal
import MetalKit

class SpherePrimitive : Primitive {
    fileprivate var indexBuffer : MTLBuffer!
    fileprivate var vertexBuffer : MTLBuffer!
    fileprivate var numIndices : Int = 0
    
    /// @param tesselationLevel: 2: 162 vertices; 3: 642 vertices; 4: 2562 vertices
    init(priority: Int, numInstances: Int, tessellationLevel: Int) {
        super.init(priority: priority, numInstances: numInstances)
        initBuffers(tessellationLevel)
    }
    
    fileprivate func initBuffers(_ tessellationLevel: Int) {
        let ps = PlatonicSolid.createIcosahedron()
        for _ in 0..<tessellationLevel {
            ps.subdivide()
        }
        var triangleList = [UInt16](repeating: 0, count: ps.faces.count * 3)
        for i in 0..<ps.faces.count {
            triangleList[3 * i] = UInt16(ps.faces[i].x)
            triangleList[3 * i + 1] = UInt16(ps.faces[i].y)
            triangleList[3 * i + 2] = UInt16(ps.faces[i].z)
        }
        numIndices = ps.faces.count * 3
        indexBuffer = RenderManager.sharedInstance.createIndexBuffer("sphere IB", elements: triangleList)
        vertexBuffer = RenderManager.sharedInstance.createTexturedVertexBuffer("sphere VB", numElements: ps.vertices.count)
        let vb = vertexBuffer.contents().assumingMemoryBound(to: TexturedVertex.self)
        for i in 0..<ps.vertices.count {
            let uv = Vec2(0, 0)
            let x = Vec3(ps.vertices[i])
            let n = Vec3(normalize(ps.vertices[i]))
            vb[i] = TexturedVertex(position: x, normal: n, uv: uv)
        }
    }
    
    override func draw(_ encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        RenderManager.sharedInstance.setUniformBuffer(encoder, atIndex: 1)
        encoder.setVertexBuffer(self.uniformBuffer, offset: 0, at: 2)
        encoder.drawIndexedPrimitives(type: .triangle, indexCount: numIndices, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0, instanceCount: self.numInstances)
    }    
}
