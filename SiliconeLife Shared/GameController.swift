//
//  GameController.swift
//  SiliconeLife Shared
//
//  Created by Romesh Niriella on 1/5/2025.
//

import SceneKit

#if os(macOS)
import AppKit
typealias SCNColor = NSColor
#else
import UIKit
typealias SCNColor = UIColor
#endif

/// Three possible states for Brian’s Brain cellular automaton.
enum CellState {
    case off     // ready
    case on      // firing
    case dying   // refractory
}

@MainActor
/// The GameController class manages the 3D Game of Life simulation including the grid setup,
/// cell state updates, rendering, and user interaction. It acts as the main coordinator for
/// initializing the scene, handling simulation logic, and updating the visual representation
/// of the cells in the 3D grid.
class GameController: NSObject, SCNSceneRendererDelegate {
    let scene: SCNScene
    let sceneRenderer: SCNSceneRenderer
    
    // Game of Life properties
    private var gridSize = (x: 10, y: 10, z: 10) // Dimensions of the 3D grid
    private var cells: [[[Cell]]] = [] // 3D array holding all cells
    private var isSimulationRunning = false // Flag to control simulation state
    private var generationTime: TimeInterval = 0.5 // Time interval between generations
    private var lastUpdateTime: TimeInterval = 0 // Timestamp of last generation update
    
    // Grid configuration
    private let cellSize: CGFloat = 1.0 // Size of each cell cube
    private let cellSpacing: CGFloat = 0.2 // Spacing between cells
    
    // Root node for all cells in the scene graph
    private let gridNode = SCNNode()
    
    /// Initializes the GameController with a given SceneKit renderer.
    /// Sets up the scene, camera, lighting, and initial grid of cells.
    /// - Parameter renderer: The SCNSceneRenderer responsible for rendering the scene.
    init(sceneRenderer renderer: SCNSceneRenderer) {
        sceneRenderer = renderer
        scene = SCNScene()

        super.init()

        setupCamera()
        setupLighting()
        setupGrid()

        // Add the grid node containing all cells to the scene's root node
        scene.rootNode.addChildNode(gridNode)

        // Assign self as the renderer delegate to receive frame update callbacks
        sceneRenderer.delegate = self
        sceneRenderer.scene = scene
        sceneRenderer.isPlaying = true

        // Debug: Print total number of cells created
        print("Total cells created: \(cells.flatMap { $0.flatMap { $0 } }.count)")
    }
    
    /// Configures and positions the camera to provide a clear view of the entire 3D grid.
    /// The camera is placed diagonally above the grid and oriented to look at its center.
    private func setupCamera() {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // Calculate extent of grid to position camera at an appropriate distance
        let gridExtent = CGFloat(max(gridSize.x, max(gridSize.y, gridSize.z))) * (cellSize + cellSpacing)
        let cameraDistance = gridExtent * 2
        
        // Position the camera diagonally above the grid
        cameraNode.position = SCNVector3(cameraDistance, cameraDistance, cameraDistance)
        
        // Calculate center point of the grid to look at
        let offset = (cellSize + cellSpacing) * CGFloat(gridSize.x - 1) / 2
        cameraNode.look(at: SCNVector3(offset, offset, offset))
        
        // Add the camera node to the scene
        scene.rootNode.addChildNode(cameraNode)
    }
    
    /// Sets up ambient and directional lighting to illuminate the 3D grid.
    /// Ambient light provides base illumination, while directional lights simulate sunlight
    /// from multiple angles to enhance depth perception and shading.
    private func setupLighting() {
        // Ambient light for soft base illumination
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 200
        ambientLight.light?.color = SCNColor.white
        scene.rootNode.addChildNode(ambientLight)
        
        // Directional lights from four different angles for dynamic lighting
        let directions: [(x: CGFloat, y: CGFloat, z: CGFloat)] = [
            (1, 1, 1),
            (-1, 1, -1),
            (1, -1, -1),
            (-1, -1, 1)
        ]
        
        for direction in directions {
            let directionalLight = SCNNode()
            directionalLight.light = SCNLight()
            directionalLight.light?.type = .directional
            directionalLight.light?.intensity = 500
            directionalLight.light?.color = SCNColor.white
            
            // Position the light at a distance along the specified direction vector
            let gridExtent = CGFloat(max(gridSize.x, max(gridSize.y, gridSize.z))) * (cellSize + cellSpacing)
            let distance = gridExtent * 2
            
            directionalLight.position = SCNVector3(
                direction.x * distance,
                direction.y * distance,
                direction.z * distance
            )
            
            // Orient the light to point towards the center of the grid
            directionalLight.look(at: SCNVector3(0, 0, 0))
            scene.rootNode.addChildNode(directionalLight)
        }
    }
    
    /// Initializes the 3D grid of cells, positioning each cell in space with proper spacing,
    /// assigning coordinates for identification, and randomly setting some cells as alive.
    /// This method prepares the initial state of the simulation.
    private func setupGrid() {
        print("Grid size: \(gridSize.x) x \(gridSize.y) x \(gridSize.z)")
        cells = []

        for x in 0..<gridSize.x {
            var yRow: [[Cell]] = []
            for y in 0..<gridSize.y {
                var zRow: [Cell] = []
                for z in 0..<gridSize.z {
                    let cell = Cell(size: cellSize)

                    let xPos = CGFloat(x) * (cellSize + cellSpacing)
                    let yPos = CGFloat(y) * (cellSize + cellSpacing)
                    let zPos = CGFloat(z) * (cellSize + cellSpacing)
                    cell.node.position = SCNVector3(xPos, yPos, zPos)

                    cell.coordinates = (x, y, z)
                    cell.node.name = "cell_\(x)_\(y)_\(z)"

                    if Double.random(in: 0...1) < 0.3 {
                        cell.state = .on
                    }

                    gridNode.addChildNode(cell.node)
                    zRow.append(cell)
                }
                yRow.append(zRow)
            }
            cells.append(yRow)
        }
    }
    
    /// Handles user selection input by performing a hit test at the given point.
    /// If a cell node is hit, toggles its alive/dead state.
    /// - Parameter point: The CGPoint in screen coordinates where the selection occurred.
    func handleSelection(at point: CGPoint) {
        let hitResults = sceneRenderer.hitTest(point, options: [:])
        guard let firstHit = hitResults.first,
              let nodeName = firstHit.node.name,
              nodeName.hasPrefix("cell_") else {
            return
        }
        
        // Extract cell coordinates from the node's name
        let components = nodeName.split(separator: "_")
        guard components.count == 4,
              let x = Int(components[1]),
              let y = Int(components[2]),
              let z = Int(components[3]) else {
            return
        }
        
        // Verify coordinates are within grid bounds
        guard x >= 0 && x < gridSize.x &&
              y >= 0 && y < gridSize.y &&
              z >= 0 && z < gridSize.z else { return }
        
        // Toggle the state of the selected cell: .off <-> .on, .dying -> .on
        let cell = cells[x][y][z]
        switch cell.state {
        case .off, .dying:
            cell.state = .on
        case .on:
            cell.state = .off
        }
    }
    
    /// Toggles the simulation running state on or off.
    /// When running, the simulation updates cell states at regular intervals.
    func toggleSimulation() {
        isSimulationRunning.toggle()
        print("Simulation is now \(isSimulationRunning ? "Running" : "Paused")")
    }
    
    /// Resets the grid by setting all cells to dead, then randomly reviving some cells.
    /// This method allows restarting the simulation with a new initial configuration.
    func resetGrid() {
        for x in 0..<gridSize.x {
            for y in 0..<gridSize.y {
                for z in 0..<gridSize.z {
                    let cell = cells[x][y][z]
                    cell.state = .off
                    if Double.random(in: 0...1) < 0.3 {
                        cell.state = .on
                    }
                }
            }
        }
    }
    
    /// Counts the number of live neighbors around a given cell, considering wrap-around edges.
    /// This method is essential for applying the 3D Game of Life rules.
    /// - Parameters:
    ///   - x: X-coordinate of the cell.
    ///   - y: Y-coordinate of the cell.
    ///   - z: Z-coordinate of the cell.
    /// - Returns: The count of live neighboring cells.
    private func countLiveNeighbors(x: Int, y: Int, z: Int) -> Int {
        var count = 0
        
        for dx in -1...1 {
            for dy in -1...1 {
                for dz in -1...1 {
                    // Skip the cell itself
                    if dx == 0 && dy == 0 && dz == 0 { continue }
                    
                    // Calculate neighbor coordinates with wrapping (toroidal grid)
                    let nx = (x + dx + gridSize.x) % gridSize.x
                    let ny = (y + dy + gridSize.y) % gridSize.y
                    let nz = (z + dz + gridSize.z) % gridSize.z
                    if cells[nx][ny][nz].state == .on {
                        count += 1
                    }
                }
            }
        }
        
        return count
    }
    
    /// Updates the state of all cells to the next generation based on Brian’s Brain rules:
    /// - Off cells become On if exactly two neighbors are On.
    /// - On cells become Dying.
    /// - Dying cells become Off.
    /// This method prepares a new state array and then applies it to all cells.
    private func updateGeneration() {
        print("Updating generation...")
        var newStates: [[[CellState]]] = Array(
            repeating: Array(
                repeating: Array(repeating: .off, count: gridSize.z),
                count: gridSize.y),
            count: gridSize.x)

        for x in 0..<gridSize.x {
            for y in 0..<gridSize.y {
                for z in 0..<gridSize.z {
                    let neighborsOn = countLiveNeighbors(x: x, y: y, z: z)
                    let oldState = cells[x][y][z].state
                    let newState: CellState
                    switch oldState {
                    case .off:
                        newState = (neighborsOn == 2) ? .on : .off
                    case .on:
                        newState = .dying
                    case .dying:
                        newState = .off
                    }
                    newStates[x][y][z] = newState
                }
            }
        }

        // Update all cells with their new states
        for x in 0..<gridSize.x {
            for y in 0..<gridSize.y {
                for z in 0..<gridSize.z {
                    cells[x][y][z].state = newStates[x][y][z]
                }
            }
        }
    }
    
    /// SCNSceneRendererDelegate method called every frame to update the scene.
    /// This method checks if the simulation is running and if enough time has passed
    /// to advance to the next generation, then updates the grid accordingly.
    /// - Parameters:
    ///   - renderer: The scene renderer.
    ///   - time: The current time.
    nonisolated func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        Task { @MainActor in
            if isSimulationRunning && (time - lastUpdateTime) >= generationTime {
                updateGeneration()
                lastUpdateTime = time
            }
        }
    }
}

/// The Cell class represents an individual cell in the 3D Brian's Brain grid.
/// Each cell manages its own visual representation and state.
class Cell {
    /// The SceneKit node representing the cell in the scene graph.
    let node: SCNNode

    /// The coordinates of this cell within the 3D grid, used for identification.
    var coordinates: (x: Int, y: Int, z: Int)?

    /// The material applied to the cell's geometry, controlling appearance.
    private let material: SCNMaterial

    /// The state of the cell (Brian's Brain: off, on, dying). When set, updates the visual appearance accordingly.
    var state: CellState = .off {
        didSet {
            updateAppearance()
        }
    }

    /// Initializes a cell with a given size, creating its geometry and material.
    /// - Parameter size: The size of the cube representing the cell.
    init(size: CGFloat) {
        let geometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0.1)
        node = SCNNode(geometry: geometry)
        material = SCNMaterial()
        node.geometry?.firstMaterial = material
        updateAppearance()
    }

    /// Updates the cell's visual appearance based on its state.
    private func updateAppearance() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        switch state {
        case .off:
            material.diffuse.contents = SCNColor.black
            material.emission.contents = SCNColor.black
            material.transparency = 0.2
        case .on:
            material.diffuse.contents = SCNColor.blue
            material.emission.contents = SCNColor.blue
            material.transparency = 1.0
        case .dying:
            material.diffuse.contents = SCNColor.gray
            material.emission.contents = SCNColor.gray
            material.transparency = 0.5
        }
        SCNTransaction.commit()
    }
}
