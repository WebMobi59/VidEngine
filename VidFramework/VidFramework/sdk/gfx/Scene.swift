//
//  Scene.swift
//  VidEngine
//
//  Created by David Gavilan on 9/1/16.
//  Copyright © 2016 David Gavilan. All rights reserved.
//

import Foundation
import UIKit
import simd

open class Scene {
    public var primitives: [Primitive] = []
    public var groups2D: [Group2D] = []
    public var lights: [LightSource] = []
    public var camera: Camera? = nil
    
    /// Adds all elements to their respective rendering queues
    public func queueAll() {
        for p in primitives {
            p.queue()
        }
        for p in groups2D {
            p.queue()
        }
        for l in lights {
            l.queue()
        }
    }
    
    /// Removes all elements from the rendering queues.
    /// They will stop being rendered, but the elements aren't destroyed.
    public func dequeueAll() {
        for p in primitives {
            p.dequeue()
        }
        for p in groups2D {
            p.dequeue()
        }
        for l in lights {
            l.dequeue()
        }
    }
    
    /// Removes all elements from rendering and remove them from the scene.
    public func removeAll() {
        dequeueAll()
        primitives.removeAll()
        groups2D.removeAll()
        lights.removeAll()
    }
    
    open func update(_ currentTime: CFTimeInterval) {
    }
    
    public init() {
    }
}
