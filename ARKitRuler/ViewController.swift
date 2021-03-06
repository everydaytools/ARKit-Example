
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var focus: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    
    private var points: (start: SCNVector3?, end: SCNVector3?)
    private var line = SCNNode()
    private var isDrawing = false
    private var canPlacePoint = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @objc private  func tapped() {
        if canPlacePoint {
            isDrawing = !isDrawing
            if isDrawing {
                points.start = nil
                points.end = nil
            }
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.measure()
        }
    }
    
    private func measure() {
        let hitResults = sceneView.hitTest(view.center, types:  [.featurePoint])
        if let hit = hitResults.first {
            canPlacePoint = true
            focus.image = UIImage(named: "focus")
            
            if isDrawing {
                let hitTransform = SCNMatrix4(hit.worldTransform)
                let hitPoint = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
                
                if points.start == nil {
                    points.start = hitPoint
                } else {
                    points.end = hitPoint
                    line.geometry = lineFrom(vector: points.start!, toVector: points.end!)
                    if line.parent == nil {
                        line.geometry?.firstMaterial?.diffuse.contents = UIColor.white
                        line.geometry?.firstMaterial?.isDoubleSided = true
                        sceneView.scene.rootNode.addChildNode(line)
                    }
                    let lenght = distance(from: points.start!, to: points.end!)
                    sizeLabel.text = String(format: "%.1f", lenght * 100.0) + " cm"
                }
            }
        } else {
            canPlacePoint = false
            focus.image = UIImage(named: "focus_off")
        }
    }
    
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
    
    func distance(from startPoint: SCNVector3, to endPoint: SCNVector3) -> Float {
        let vector = SCNVector3Make(startPoint.x - endPoint.x, startPoint.y - endPoint.y, startPoint.z - endPoint.z)
        let distance = sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        return distance
    }
}

