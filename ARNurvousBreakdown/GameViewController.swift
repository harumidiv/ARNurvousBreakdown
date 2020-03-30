//
//  GameViewController.swift
//  ARNurvousBreakdown
//
//  Created by 佐川 晴海 on 2020/03/29.
//  Copyright © 2020 佐川 晴海. All rights reserved.
//

import UIKit
import RealityKit

class GameViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anchor:AnchorEntity = AnchorEntity(plane: .horizontal,
                                               minimumBounds: [0.2, 0.2])
        arView.scene.addAnchor(anchor)
        
        var cards:[Entity]  = []
        for _ in 1...4 {
            let box = MeshResource.generateBox(width: 0.04, height: 0.002, depth: 0.04)
            let metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            model.generateCollisionShapes(recursive: true)
            cards.append(model)
            
        }
        
        for (index, card) in cards.enumerated() {
            let x = Float(index % 2)
            let z = Float(index / 2)
            card.position = [x * 0.1, 0, z * 0.1]
            anchor.addChild(card)
            
        }
    }
}
