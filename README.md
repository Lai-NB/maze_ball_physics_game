# Maze Ball Physics Game

A 3D physics-based maze game developed using Processing (Java Mode).

Players control a rolling ball by tilting the board, navigating through maze obstacles, avoiding holes, and reaching the goal area as quickly as possible.

---
## Gameplay Preview

<p align="center">
  <img src="screenshots/main-menu.png" width="45%">
  <img src="screenshots/tutorial.png" width="45%">
</p>

<p align="center">
  <img src="screenshots/gameplay.png" width="45%">
  <img src="screenshots/game-won.png" width="45%">
</p>

---

## Features

* Physics-based rolling ball
* Gravity simulation using board tilt
* Circle vs AABB collision detection
* Friction and restitution system
* Interactive main menu
* Tutorial screen
* High scores system
* Win screen with timer
* Persistent TXT leaderboard
* 3D maze gameplay

---

## Controls

| Key | Function             |
| --- | -------------------- |
| W   | Tilt board up        |
| S   | Tilt board down      |
| A   | Tilt board left      |
| D   | Tilt board right     |
| Q   | Increase restitution |
| E   | Decrease restitution |
| Z   | Increase friction    |
| C   | Decrease friction    |

---

## Built With

* Processing (Java Mode)
* Java / PVector
* P3D Renderer

---

## Physics Concepts Implemented

* Gravity simulation
* Acceleration and velocity
* Symplectic Euler integration
* Friction
* Restitution
* Collision detection
* Collision response impulse

---

## How To Run

### Using Processing

1. Install Processing:
   https://processing.org/download

2. Open the `MazeBall.pde` sketch file.

3. Click the **Run** button.

---

## Download Playable Version

Download the latest playable build from the repository Releases section.

---

## Project Structure

```text
MazeBall/
├── MazeBall.pde
├── data/
│   └── highscores.txt
├── screenshots/
├── README.md
```

---

## Screenshots Folder

Place these images inside the `screenshots` folder:

* `main-menu.png`
* `tutorial.png`
* `gameplay.png`
* `game-won.png`

---

## Author

Lai Yong Kang

---

## License

This project was created for educational purposes.
