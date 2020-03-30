//
//  GameViewController.swift
//  ARNurvousBreakdown
//
//  Created by 佐川 晴海 on 2020/03/29.
//  Copyright © 2020 佐川 晴海. All rights reserved.
//

import UIKit
import RealityKit
import Combine

class GameViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    private var cards:[Entity]  = []
    private let cardConstantNum = 16
    private let anchor:AnchorEntity = AnchorEntity(plane: .horizontal,minimumBounds: [0.2, 0.2])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.scene.addAnchor(anchor)
        
        for _ in 1...cardConstantNum {
            let box = MeshResource.generateBox(width: 0.04, height: 0.002, depth: 0.04)
            let metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            model.generateCollisionShapes(recursive: true)
            cards.append(model)
            
        }
        
        for (index, card) in cards.enumerated() {
            let x = Float(index % 4)
            let z = Float(index / 4)
            card.position = [x * 0.1, 0, z * 0.1]
            anchor.addChild(card)
        }
        
        //裏になっている時にオブジェクトを隠す
        let boxSize: Float = 0.7
        let occlusionBoxMesh = MeshResource.generateBox(size: boxSize)
        let occlusionBox = ModelEntity(mesh: occlusionBoxMesh, materials: [OcclusionMaterial()])
        occlusionBox.position.y = -boxSize/2
        anchor.addChild(occlusionBox)
        
        var cancellable: AnyCancellable? = nil
        
        //TODO: モデルのサイズがバラバラになってしまっているので統一する
        cancellable = ModelEntity.loadModelAsync(named: "Model/chair_swan")
            .append(ModelEntity.loadModelAsync(named: "Model/cup_saucer_set"))
            .collect()
            .sink(receiveCompletion: { error in
               print("error:\(error)")
                cancellable?.cancel()
            }, receiveValue: { entities in
                var objects: [ModelEntity] = []
                for entity in entities {
                    entity.setScale(SIMD3<Float>(0.002, 0.002, 0.002),relativeTo: self.anchor)
                    entity.generateCollisionShapes(recursive: true)
                    for _ in 1...2 {
                        objects.append(entity.clone(recursive: true))
                        
                    }
                }
                objects.shuffle()
                
                //カードにARオブジェクトを追加する
                for (index, object) in objects.enumerated() {
                    self.cards[index].addChild(object)
                    self.cards[index].transform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                }
                
                cancellable?.cancel()
        })
        
    }
    
    // MARK: Event
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
