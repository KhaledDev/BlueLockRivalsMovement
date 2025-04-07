# Blue Lock Rivals Soccer Ball Physics System

A comprehensive soccer ball physics system inspired by Blue Lock Rivals, with adjustments to curve and velocity mechanics.

## Setup Instructions

1. Place a ball in your workspace named "SoccerBall"
   - It should be a sphere with proper physics properties
   - Size recommendation: 2x2x2 studs

2. The scripts are organized for a Rojo project structure:
   - `BallPhysicsModule.luau` in src/shared/
   - `BallPhysicsServer.luau` in src/server/
   - `BallPhysicsClient.luau` in src/client/

3. Create animations for the following actions (optional):
   - Dribbling
   - Kicking
   - Tackling
   - Shooting
   
   Then replace the placeholder animation IDs in the client script.

## Controls

- E: Dribble (Toggle)
- F: Kick
- T: Tackle
- Left Mouse Button: Shoot (hold to charge)

## Features

### Ball Physics
- Realistic ball physics with configurable parameters
- Proper collision and bouncing mechanics
- Customizable mass, elasticity, friction, and damping

### Tackling
- Distance-based tackle system
- Knockback effect on tackled player
- Ball separation from tackled player

### Dribbling
- Ball welds to player's foot during dribble
- Dynamic animation during ball control
- Proper ball placement relative to player

### Shooting
- Power charging system
- Customizable curve effects
- Direction based on player's orientation

### Welding System
- Ball welding to player during dribble
- Seamless transitions between dribbling and other actions
- Visual indicator of which player has ball control

## Customization

All physics parameters can be adjusted in the `BallPhysicsModule.luau` file.