local BallPhysics = {}

BallPhysics.Shooting = {
    UpForce = Vector3.new(0,50,0),
    Force = 60,
    Bouncyness = 1,
    TimetoPickUp = 0.1,
}

BallPhysics.Passing = {
    UpForce = Vector3.new(0,30,0),
    Force = 100,
    Bouncyness = 0.5,
    TimetoPickUp = 0.1,
}

BallPhysics.Dribble = {
    DribbleStartupTime = 0.05,
    DribbleTime = 0.1
}

BallPhysics.Tackle = {
    TackleTime = 0.1,
    TackleDistance = 5, -- the distance to stop the animation at
    TackleForce = 500,
    Range = 10, -- Distance from the player to the ball
    TackleCooldown = 1, -- Time before the player can tackle again
}

BallPhysics.Rainbowflick = {
    UpForce = Vector3.new(0,15,0),
    FrontForce = 20,
    TimetoPickUp = 0.5
}

return BallPhysics