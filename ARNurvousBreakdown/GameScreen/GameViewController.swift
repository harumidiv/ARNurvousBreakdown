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
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLogation = sender.location(in: arView)
        if let card = arView.entity(at: tapLogation) {
            if card.transform.rotation.angle == .pi {
                var flipDownTransform = card.transform
                flipDownTransform.rotation = simd_quatf(angle: 0, axis: [1, 0, 0])
                card.move(to: flipDownTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeOut)
            } else {
                var flipUpTransform = card.transform
                flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeOut)
            }
        }
        
        
    }
}
