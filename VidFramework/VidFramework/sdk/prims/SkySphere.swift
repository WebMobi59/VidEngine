//
//  SkySphere.swift
//  VidFramework
//
//  Created by David Gavilan on 2019/05/11.
//  Copyright © 2019 David Gavilan. All rights reserved.
//

import MetalKit

public class SkySphere: EnvironmentSphere {
    public init(radius: Float, widthSegments: Int, heightSegments: Int) {
        super.init(isInterior: true, widthSegments: widthSegments, heightSegments: heightSegments)
        name = "SkySphere"
        transform = Transform(position: .zero, scale: 2 * radius)
    }
}
