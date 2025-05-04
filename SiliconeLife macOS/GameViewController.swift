//
//  GameViewController.swift
//  SiliconeLife macOS
//
//  Created by Romesh Niriella on 1/5/2025.
//

import Cocoa
import SceneKit
import AppKit

class GameViewController: NSViewController {
    
    private var gameController: GameController!
    private var sceneView: SCNView!
    
    override func loadView() {
        let mainView = NSView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        sceneView = SCNView(frame: mainView.bounds)
        sceneView.autoresizingMask = [.width, .height]
        mainView.addSubview(sceneView)
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
        setupUI()
        setupMouseHandling()
    }
    
    private func setupSceneView() {
        sceneView = view.subviews.compactMap { $0 as? SCNView }.first
        sceneView?.backgroundColor = .black
        
        if let sceneView = sceneView {
            gameController = GameController(sceneRenderer: sceneView)
            sceneView.isPlaying = true
            
            sceneView.allowsCameraControl = true
            sceneView.defaultCameraController.interactionMode = .fly
            sceneView.defaultCameraController.inertiaEnabled = true
        }
    }
    
    private func setupUI() {
        view.wantsLayer = true
        
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.spacing = 10
        
        let playPauseButton = NSButton(title: "Play/Pause", target: self, action: #selector(toggleSimulation))
        playPauseButton.bezelStyle = .rounded
        
        let resetButton = NSButton(title: "Reset", target: self, action: #selector(resetGrid))
        resetButton.bezelStyle = .rounded
        
        stackView.addArrangedSubview(playPauseButton)
        stackView.addArrangedSubview(resetButton)
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupMouseHandling() {
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        sceneView.addGestureRecognizer(clickGesture)
    }
    
    @objc private func handleClick(_ gesture: NSGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        gameController.handleSelection(at: location)
    }
    
    @objc private func toggleSimulation() {
        gameController.toggleSimulation()
    }
    
    @objc private func resetGrid() {
        gameController.resetGrid()
    }
}
