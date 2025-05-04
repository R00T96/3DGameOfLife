//
//  GameViewController.swift
//  SiliconeLife iOS
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
        setupGestures()
    }
    
    private func setupSceneView() {
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.backgroundColor = .black
        view.addSubview(sceneView)
        
        gameController = GameController(sceneRenderer: sceneView)
        
        sceneView.allowsCameraControl = true
        sceneView.defaultCameraController.interactionMode = .fly
        sceneView.defaultCameraController.inertiaEnabled = true
    }
    
    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        let playPauseButton = UIButton(type: .system)
        playPauseButton.setTitle("Play/Pause", for: .normal)
        playPauseButton.addTarget(self, action: #selector(toggleSimulation), for: .touchUpInside)
        
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(resetGrid), for: .touchUpInside)
        
        stackView.addArrangedSubview(playPauseButton)
        stackView.addArrangedSubview(resetButton)
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        gameController.handleSelection(at: location)
    }
    
    @objc private func toggleSimulation() {
        gameController.toggleSimulation()
    }
    
    @objc private func resetGrid() {
        gameController.resetGrid()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
