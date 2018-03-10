//
//  ViewController.swift
//  SampleColorPalette
//
//  Created by David Gavilan on 2018/02/24.
//  Copyright © 2018 David Gavilan. All rights reserved.
//

import UIKit
import VidFramework
import simd
import MetalKit
import Photos

class ViewController: VidController {
    var sampler: P3MinusSrgbSampler?
    var samples: [LinearRGBA] = []
    var updateFn: ((TimeInterval) -> ())?
    var framesTilInit = 0
    weak var imageViewP3: UIButton?
    weak var imageViewSRGB: UIButton?
    var myFilters: MyFilters?
    var som: SelfOrganizingMap?

    override func viewDidLoad() {
        super.viewDidLoad()
        initSprites()
        initTexture()
        camera.setBounds(view.bounds)
        // bits = 7 -> 1039 * 602 samples
        sampler = P3MinusSrgbSampler(bitsPerChannel: 7)
        updateFn = self.updateSamples
        initImageViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func update(_ elapsed: TimeInterval) {
        updateFn?(elapsed)
        if som?.isCompleted == true {
            if let output = som?.output {
                initMyFilters(input: output)
                imageViewP3?.setBackgroundImage(UIImage(texture: output), for: .normal)
            }
            som = nil
        }
        if myFilters?.isCompleted == true {
            if let mtlTexture = myFilters?.p3TosRgb.chain.last?.output {
                imageViewSRGB?.setBackgroundImage(UIImage(texture: mtlTexture), for: .normal)
            }
            if let mtlTexture = myFilters?.p3ToGammaP3.chain.last?.output {
                imageViewP3?.setBackgroundImage(UIImage(texture: mtlTexture), for: .normal)
            }
            myFilters = nil
        }
    }
    
    private func updateSamples(_ elapsed: TimeInterval) {
        let start = DispatchTime.now()
        let choppyFramerate = 2 * elapsed
        var outOfTime = false
        while let p3 = sampler?.getNextSample(), !outOfTime {
            samples.append(p3)
            let nanoTime = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            outOfTime = timeInterval > choppyFramerate
        }
        if !outOfTime {
            // done!
            didInitSamples()
            updateFn = nil
        }
        framesTilInit += 1
    }
    
    private func didInitSamples() {
        let ratio = (100 * Float(samples.count) / Float(sampler?.volume ?? 0)).rounded(toPlaces: 4)
        print("#samples: \(samples.count); \(ratio)% of the P3 space not covered by sRGB")
        print("-- Computed in \(framesTilInit) frames")
        guard let library = device.makeDefaultLibrary() else {
            NSLog("Failed to create default Metal library")
            return
        }
        som = SelfOrganizingMap(device: device, library: library, width: 128, height: 128, numIterations: 10000, trainingData: samples)
        Primitive2D.texture = som?.output
        som?.queue()
    }
    
    private func initSprites() {
        let sprite = SpritePrimitive2D(priority: 0)
        sprite.options = [.alignCenter]
        sprite.position = Vec3(0, 0, 0)
        sprite.width = 320
        sprite.height = 320
        sprite.queue()
    }

    private func initTexture() {
        guard let url = Bundle.main.url(forResource: "iconAbout", withExtension: "png") else {
            return
        }
        let textureLoader = MTKTextureLoader(device: device)
        textureLoader.newTexture(URL: url, options: nil) { (texture, error) in
            Primitive2D.texture = texture
        }
    }
    
    private func createButton() -> UIButton {
        let button = UIButton(frame: CGRect())
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(ViewController.buttonAction(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(button)
        return button
    }
    
    @objc func buttonAction(_ sender:UIButton!) {
        if let image = sender.backgroundImage(for: .normal) {
            saveImage(image: image)
        }
    }
    
    private func initImageViews() {
        self.imageViewP3 = createButton()
        self.imageViewSRGB = createButton()
    }
    
    override func viewDidLayoutSubviews() {
        let s: CGFloat = 180
        imageViewP3?.frame = CGRect(x: 0.25 * view.frame.width - 0.5 * s, y: view.frame.height - s - 10, width: s, height: s)
        imageViewSRGB?.frame = CGRect(x: 0.75 * view.frame.width - 0.5 * s, y: view.frame.height - s - 10, width: s, height: s)
    }
    
    private func initMyFilters(input: MTLTexture) {
        guard let m = sampler?.p3ToSrgb else {
            NSLog("Missing sampler")
            return
        }
        let colorTransform = float4x4([
            float4(m[0].x, m[0].y, m[0].z, 0),
            float4(m[1].x, m[1].y, m[1].z, 0),
            float4(m[2].x, m[2].y, m[2].z, 0),
            float4(0, 0, 0, 1),
            ])
        myFilters = MyFilters(device: device, input: input, colorTransform: colorTransform)
    }
    
    func saveImage(image: UIImage) {
        guard let data = UIImagePNGRepresentation(image) else {
            NSLog("Failed to create PNG representation")
            return
        }
        // Perform changes to the library
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
        }, completionHandler: { success, error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
        })
    }
}

