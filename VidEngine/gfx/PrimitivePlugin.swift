//
//  PrimitivePlugin.swift
//  VidEngine
//
//  Created by David Gavilan on 8/11/16.
//  Copyright © 2016 David Gavilan. All rights reserved.
//

import Metal
import MetalKit

class PrimitivePlugin : GraphicPlugin {
    
    private var primitives : [Primitive] = []
    private var pipelineState: MTLRenderPipelineState! = nil
    private var depthState : MTLDepthStencilState! = nil
    private var whiteTexture : MTLTexture! = nil
    
    func queue(primitive: Primitive) {
        let alreadyQueued = primitives.contains { $0 === primitive }
        if !alreadyQueued {
            // @todo insert in priority order
            primitives.append(primitive)
        }
    }
    
    func dequeue(primitive: Primitive) {
        let index = primitives.indexOf { $0 === primitive }
        if let i = index {
            primitives.removeAtIndex(i)
        }
    }
    
    override init(device: MTLDevice, view: MTKView) {
        super.init(device: device, view: view)
        
        let defaultLibrary = device.newDefaultLibrary()!
        let fragmentProgram = defaultLibrary.newFunctionWithName("passLightFragment")!
        let vertexProgram = defaultLibrary.newFunctionWithName("passLightGeometry")!
        
        // check TexturedVertex
        let vertexDesc = MTLVertexDescriptor()
        vertexDesc.attributes[0].format = .Float3
        vertexDesc.attributes[0].offset = 0
        vertexDesc.attributes[0].bufferIndex = 0
        vertexDesc.attributes[1].format = .Float3
        vertexDesc.attributes[1].offset = sizeof(Vec3)
        vertexDesc.attributes[1].bufferIndex = 0
        vertexDesc.attributes[2].format = .Float2
        vertexDesc.attributes[2].offset = sizeof(Vec3) * 2
        vertexDesc.attributes[2].bufferIndex = 0
        vertexDesc.layouts[0].stepFunction = .PerVertex
        vertexDesc.layouts[0].stride = sizeof(TexturedVertex)
        
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.vertexDescriptor = vertexDesc
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.colorAttachments[0].blendingEnabled = false
        pipelineStateDescriptor.sampleCount = view.sampleCount
        pipelineStateDescriptor.depthAttachmentPixelFormat = .Depth32Float
        
        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch let error {
            print("Failed to create pipeline state, error \(error)")
        }
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthWriteEnabled = true
        depthDescriptor.depthCompareFunction = .Less
        depthState = device.newDepthStencilStateWithDescriptor(depthDescriptor)
        whiteTexture = RenderManager.sharedInstance.createWhiteTexture()
    }
    
    override func execute(encoder: MTLRenderCommandEncoder) {
        encoder.pushDebugGroup("primitives")
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.setFrontFacingWinding(.CounterClockwise)
        encoder.setCullMode(.Back)
        encoder.setFragmentTexture(whiteTexture, atIndex: 0)

        RenderManager.sharedInstance.setUniformBuffer(encoder, atIndex: 1)
        for p in self.primitives {
            p.draw(encoder)
        }
        encoder.popDebugGroup()
    }
    
    override func updateBuffers(syncBufferIndex: Int) {
        for p in primitives {
            p.updateBuffers(syncBufferIndex)
        }
    }
}