# 3D Brian's Brain Game of Life

A modular, cross-platform 3D implementation of Brian's Brain cellular automaton using SceneKit for macOS, iOS, and tvOS.

## Features
- **3D Brian's Brain Automaton**: Simulates Brian's Brain rules in a 3D toroidal grid.
- **SceneKit Rendering**: Real-time, animated visualization of cell states in 3D.
- **Cross-Platform**: Shared codebase for macOS, iOS, and tvOS targets.
- **Interactive**: Select and toggle cell states with mouse/touch. Start, pause, and reset the simulation.
- **Configurable**: Easily adjust grid size, cell size, and simulation speed in code.
- **SOLID, Modular Design**: Clean, extensible architecture for easy modification and testing.

## Rules (Brian's Brain)
- **Off** (ready): Becomes **On** (firing) if exactly two neighbors are **On**.
- **On** (firing): Becomes **Dying** (refractory).
- **Dying** (refractory): Becomes **Off** (ready).
- All edges wrap (toroidal grid).

## Directory Structure
```
3DGameOfLife/
  SiliconeLife Shared/         # Shared code and assets
    GameController.swift       # Main simulation logic
    ...
  SiliconeLife macOS/         # macOS-specific files
  SiliconeLife iOS/           # iOS-specific files
  SiliconeLife tvOS/          # tvOS-specific files
  ...
```

## Getting Started
### Prerequisites
- Xcode 14+
- macOS 12+, iOS 15+, or tvOS 15+

### Build & Run
1. Open `GameOfLife.xcodeproj` in Xcode.
2. Select your target platform (macOS, iOS, or tvOS).
3. Build and run.

## Usage
- **Start/Pause**: Use the UI or call `toggleSimulation()` in code.
- **Reset**: Use the UI or call `resetGrid()` in code.
- **Select Cell**: Click/tap a cell to toggle its state.

## Configuration
Edit `GameController.swift`:
- `gridSize`: Change the 3D grid dimensions.
- `generationTime`: Adjust simulation speed.
- `cellSize` and `cellSpacing`: Change cell appearance.

## Code Quality
- SOLID, modular, and expressive code.
- Behavior-driven validation and clear separation of concerns.

## License
MIT 