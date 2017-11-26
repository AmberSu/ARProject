//
//  ViewController.swift
//  AugmentedRealityApp
//
//  Created by MacOS on 26/11/2017.
//  Copyright © 2017 amberApps. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var objectPicker: UIPickerView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var configuration: ARConfiguration = AROrientationTrackingConfiguration()
        if ARWorldTrackingConfiguration.isSupported {
            configuration = ARWorldTrackingConfiguration()
        }
        sceneView.session.run(configuration)
        objectPicker.selectRow(2, inComponent: 0, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: Camera coordinate method
    struct myCameraCoordinates {
        var x = Float()
        var y = Float()
        var z = Float()
    }
    
    private func getCameraCoordinates(sceneView: ARSCNView) -> myCameraCoordinates {
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        
        var cameraCoord = myCameraCoordinates()
        cameraCoord.x = cameraCoordinates.translation.x
        cameraCoord.y = cameraCoordinates.translation.y
        cameraCoord.z = cameraCoordinates.translation.z
        
        return cameraCoord
    }
    // MARK: Swipe methods
    
    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        objectPicker.isHidden = false
    }
    
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        objectPicker.isHidden = true
    }
    
    // MARK: PickerView methods
    
    var objects = ["Cube", "Lamp", "Vase", "Chair", "Cup"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return objects[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return objects.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch objects[row] {
        case "Cube": addCube()
        case "Lamp": addObject(name: "lamp")
        case "Vase": addObject(name: "vase")
        case "Chair": addObject(name: "chair")
        case "Cup": addObject(name: "cup")
        default: break
        }
    }
    
    // MARK: function for adding a cube
    
    private func addCube() {
        let cube: SCNGeometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        let cubeNode = SCNNode(geometry: cube)
        let cameraCoordinates = getCameraCoordinates(sceneView: sceneView)
        cubeNode.position = SCNVector3(cameraCoordinates.x, cameraCoordinates.y, cameraCoordinates.z)
        let cubeMaterial = SCNMaterial()
        cubeMaterial.diffuse.contents = UIImage(named: "planet")
        cube.materials = [cubeMaterial]
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    
    // MARK: function for adding a room object
    
    private func addObject(name: String) {
        let objectNode = SCNNode()
        let cameraCoordinates = getCameraCoordinates(sceneView: sceneView)
        objectNode.position = SCNVector3(cameraCoordinates.x, cameraCoordinates.y, cameraCoordinates.z)
        guard let virtualObjectScene = SCNScene(named: name + ".scn", inDirectory: "Models.scnassets/" + name) else {
            return
        }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        objectNode.addChildNode(wrapperNode)
        sceneView.scene.rootNode.addChildNode(objectNode)
    }
}
