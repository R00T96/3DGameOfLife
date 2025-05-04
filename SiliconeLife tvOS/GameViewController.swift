//
//  GameViewController.swift
//  SiliconeLife tvOS
//
//  Created by Romesh Niriella on 1/5/2025.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    private var gameController: GameController!
    private var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
        setupUI()
    }
    
    private func setupSceneView() {
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.backgroundColor = .black
        view.addSubview(sceneView)
        
        gameController = GameController(sceneRenderer: sceneView)
        
        // For tvOS, we'll set up a default camera animation to showcase the 3D grid
        setupCameraAnimation()
    }
    
    private func setupCameraAnimation() {
        guard let cameraNode = gameController.scene.rootNode.childNodes.first(where: { $0.camera != nil }) else {
            return
        }
        
        let rotateAction = SCNAction.rotateBy(x: 0, y: Float.pi * 2, z: 0, duration: 30)
        let repeatAction = SCNAction.repeatForever(rotateAction)
        cameraNode.runAction(repeatAction)
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 50
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        let playPauseButton = UIButton(type: .system)
        playPauseButton.setTitle("Play/Pause", for: .normal)
        playPauseButton.addTarget(self, action: #selector(toggleSimulation), for: .primaryActionTriggered)
        
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetGrid), for: .primaryActionTriggered)
        
        stackView.addArrangedSubview(playPauseButton)
        stackView.addArrangedSubview(resetButton)
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Make buttons larger for TV
        [playPauseButton, resetButton].forEach { button in
            button.titleLabel?.font = .systemFont(ofSize: 40)
            button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 40, bottom: 20, right: 40)
        }
    }
    
    @objc private func toggleSimulation() {
        gameController.toggleSimulation()
    }
    
    @objc private func resetGrid() {
        gameController.resetGrid()
    }
}
