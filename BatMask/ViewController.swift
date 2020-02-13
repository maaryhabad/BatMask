//
//  ViewController.swift
//  
//
//  Created by Mariana Beilune Abad on 05/02/20.
//  Copyright © 2020 Mariana Beilune Abad. All rights reserved.
//

import UIKit
import ARKit

private let planeWidth: CGFloat = 0.26
private let planeHeight: CGFloat = 0.26
private let nodeYPosition: Float = 0.022
private let minPositionDistance: Float = 0.0025
private let minScaling: CGFloat = 0.025
private let cellIdentifier = "MaskCollectionViewCell"
private let masksCount = 4
private let animationDuration: TimeInterval = 0.25
private let cornerRadius: CGFloat = 10

class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var masksView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calibrationView: UIView!
    @IBOutlet weak var calibrationTransparentView: UIView!
    @IBOutlet weak var collectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calibrationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var calibrationButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    
    
    private let masksPlane = SCNPlane(width: planeWidth, height: planeHeight)
    private let masksNode = SCNNode()
    
    private var scaling: CGFloat = 1
    
    private var isCollectionOpened = false {
        didSet {
            updateCollectionPosition()
        }
    }
    private var isCalibrationOpened = false {
        didSet {
            updateCalibrationPosition()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard ARFaceTrackingConfiguration.isSupported else {
            alertLabel.text = "Face tracking não está disponível nesse dispositivo."
            
            return
        }
        
        calibrationTransparentView.backgroundColor = UIColor(patternImage: UIImage(named: "Fundo.png")!)
        calibrationView.layer.cornerRadius = 10
        
        sceneView.delegate = self
        
        setupCollectionView()
        setupCalibrationView()
    }
    
    @IBAction func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let gestureView = gesture.view else {
          return
        }
        gesture.scale = 1
        print("gesto")
    
        if gesture.state == .changed {
            
            print("entrou no if")
            print(gesture.velocity)
            scaling += gesture.velocity * 0.01
            updateSize()
        }


    }
    
    var lastPoint: CGPoint!
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: sceneView)
        if lastPoint == nil {
            lastPoint = point
            return
        }
        let offset = CGPoint(x: lastPoint.x - point.x, y: lastPoint.y - point.y)
        lastPoint = point
        
        print("início: ", masksNode.position)
        print(point)
        masksNode.position.x -= minPositionDistance * Float(offset.x * 0.09)
        masksNode.position.y += minPositionDistance * Float(offset.y * 0.09)
        
        print(masksNode.position)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionBottomConstraint.constant = -masksView.bounds.size.height
    }
    
    private func setupCalibrationView() {
        calibrationTransparentView.layer.cornerRadius = cornerRadius
        calibrationBottomConstraint.constant = -calibrationView.bounds.size.height
    }
    
    private func updateMasks(with index: Int) {
        let imageName = "mask\(index)"
        masksPlane.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    }
    
    private func updateCollectionPosition() {
        collectionBottomConstraint.constant = isCollectionOpened ? 0 : -masksView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.calibrationButton.alpha = self.isCollectionOpened ? 0 : 1
            self.collectionButton.alpha = self.isCalibrationOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCalibrationPosition() {
        calibrationBottomConstraint.constant = isCalibrationOpened ? 0 : -calibrationView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.collectionButton.alpha = self.isCalibrationOpened ? 0 : 1
            self.calibrationButton.alpha = self.isCollectionOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateSize() {
        masksPlane.width = scaling * planeWidth
        masksPlane.height = scaling * planeHeight
    }
    
    // MARK: - Actions
    
    @IBAction func collectionDidTap(_ sender: UIButton) {
        isCollectionOpened = !isCollectionOpened
    }
    
    @IBAction func calibrationDidTap(_ sender: UIButton) {
        isCalibrationOpened = !isCalibrationOpened
    }
    
    @IBAction func sceneViewDidTap(_ sender: UITapGestureRecognizer) {
        isCollectionOpened = false
        isCalibrationOpened = false
    }
    
    @IBAction func upDidTap(_ sender: UIButton) {
        masksNode.position.y += minPositionDistance
    }
    
    @IBAction func downDidTap(_ sender: UIButton) {
        masksNode.position.y -= minPositionDistance
    }
    
    @IBAction func leftDidTap(_ sender: UIButton) {
        masksNode.position.x -= minPositionDistance
    }
    
    @IBAction func rightDidTap(_ sender: UIButton) {
        masksNode.position.x += minPositionDistance
    }
    
    @IBAction func farDidTap(_ sender: UIButton) {
        masksNode.position.z += minPositionDistance
    }
    
    @IBAction func closerDidTap(_ sender: UIButton) {
        masksNode.position.z -= minPositionDistance
    }
    
    @IBAction func biggerDidTap(_ sender: UIButton) {
        scaling += minScaling
        updateSize()
    }
    
    @IBAction func smallerDidTap(_ sender: UIButton) {
        scaling -= minScaling
        updateSize()
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.transparency = 0
        
        masksPlane.firstMaterial?.isDoubleSided = true
        updateMasks(with: 0)
        
        masksNode.position.z = faceNode.boundingBox.max.z * 3 / 4
        masksNode.position.y = nodeYPosition
        masksNode.geometry = masksPlane

        faceNode.addChildNode(masksNode)
        
        return faceNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return masksCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MaskCollectionViewCell
        let imageName = "mask\(indexPath.row)"
        print(imageName)
        cell.setup(with: imageName)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateMasks(with: indexPath.row)
    }
}

