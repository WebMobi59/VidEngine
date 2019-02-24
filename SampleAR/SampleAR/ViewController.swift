//
//  ViewController.swift
//  SampleAR
//
//  Created by David Gavilan on 2018/08/19.
//  Copyright © 2018 David Gavilan. All rights reserved.
//

import UIKit
import VidFramework
import ARKit

class ViewController: VidController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let cfg = ARWorldTrackingConfiguration()
        cfg.planeDetection = .horizontal
        cfg.environmentTexturing = .manual
        arConfiguration = cfg
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupScene()
    }

    private func setupScene() {
        let cube = CubePrimitive(numInstances: 1)
        cube.transform.position = float3(0, 0, -2)
        cube.transform.scale = float3(0.2, 0.2, 0.2)
        cube.queue()
        let sun = DirectionalLight(numInstances: 1)
        sun.color = LinearRGBA(r: 1, g: 0.9, b: 0.8, a: 1.0)
        sun.direction = normalize(float3(1, 1, 1))
        sun.queue()
    }
    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {
        // Create anchor using the camera's current position
        if let session = arSession {
            // place the cube a bit further away from the camera
            let pos = camera.transform * float3(0, 0, -0.2)
            print(pos)
            addCube(position: pos)
            addLightProbe(position: pos, session: session)
        }
    }
    
    func addCube(position: float3) {
        let cube = CubePrimitive(numInstances: 1)
        cube.transform.position = position
        cube.transform.scale = float3(0.1, 0.1, 0.1)
        cube.queue()
    }
    
    func addLightProbe(position: float3, session: ARSession) {
        let extent = float3(5, 5, 5)
        let probe = SHLight(position: position, extent: extent, session: session)
        probe.queue()
    }
}

