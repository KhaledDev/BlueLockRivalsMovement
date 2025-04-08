# Blue Lock Rivals Movement System

A comprehensive soccer ball physics and player movement system inspired by Blue Lock Rivals, featuring realistic ball interactions and player controls.

## 📋 Overview

This system provides a complete implementation of soccer mechanics including ball physics, player movement, and ball interactions such as dribbling, passing, shooting with curve effects, tackling, and more. The system is designed to be highly customizable while maintaining realistic physics.

## ✨ Features

### Ball Physics
- Realistic ball physics with configurable parameters
- Proper collision handling with environment and players
- Customizable mass, elasticity, friction, and damping
- Ball welding to players during possession

### Player Controls
- Sprint system with stamina management
- Shift-lock camera for precise control
- Fluid animation transitions between actions

### Ball Interactions
- **Dribbling**: Control the ball at your feet while moving
- **Passing**: Adjustable power and curve based on charge time
- **Shooting**: Power charging system with visual feedback
- **Tackling**: Distance-based tackle system to steal the ball
- **Rainbow Flick**: Special move to flip the ball over opponents

### Visual Feedback
- Charging UI for shooting and passing
- Stamina meter for sprint management
- Smooth animations for all actions

## 🎮 Controls

| Action | Control | Description |
|--------|---------|-------------|
| Move | WASD | Player movement |
| Sprint | Shift | Temporary speed boost (uses stamina) |
| Camera Lock | Left Ctrl | Toggle shift-lock camera |
| Dribble | Q | Control the ball at your feet |
| Tackle | E | Attempt to take the ball from opponents |
| Shoot | Left Mouse (hold) | Charge shot power (longer = more power) |
| Pass | Right Mouse (hold) | Charge pass power (longer = more power) |
| Rainbow Flick | Space | Flip the ball up and over |

## 🛠️ Technical Implementation

### Architecture
- Server-side ball physics to prevent cheating
- Client-side prediction for responsive controls
- Event-based communication between client and server
- Animation synchronization for realistic movements

### Components
- **BallPhysics**: Core server-side physics implementation
- **SprintService**: Client-side stamina and speed management
- **RagdollService**: Handles player knockdown during tackles
- **BallPlayer**: Client-side input handling and animations

## 💻 Setup Instructions

### Prerequisites
- Rojo (7.4.4 or newer)
- Aftman or foreman
- A Roblox project

### Installation
1. Clone this repository
2. Use Aftman or foreman to install rojo
   ```
   aftman install
   ```
   OR
   ```
   foreman install
   ```
3. Use Rojo to sync the project to Roblox Studio
   ```
   rojo serve
   ```
4. Connect to the Rojo server from Roblox Studio

### Configuration
All physics parameters can be adjusted in `src/shared/Modules/BallPhysics.luau`:
- Ball properties (bounciness, weight, etc.)
- Shooting force and curve
- Passing power and accuracy
- Tackle distance and effectiveness
- Dribbling control parameters

## 🎬 Animation Setup

The system uses the following animations that can be customized:
- Slide Tackle: Default ID "116367868199348"
- Kick Ready Pose: Default ID "113902481186836"
- Kick: Default ID "106423748928091"
- Dribble: Default ID "131192896107847"

Replace these IDs in `src/client/BallPlayer.client.luau` with your custom animations.

## 🧪 Customization

### Physics Tuning
Adjust values in `BallPhysics.luau` to change:
- Shot power and trajectory
- Ball bounciness and friction
- Tackle effectiveness and recovery
- Player movement speeds

### Visual Customization
- Modify UI elements for stamina and charge bars
- Adjust camera positioning and behavior
- Change animation speeds and transitions

## 🔗 Credits

Developed as a recreation of the movement system from Blue Lock Rivals.