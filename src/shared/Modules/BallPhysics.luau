local BallPhysics = {}

BallPhysics.Shooting = {
    Force = 150,
    Bouncyness = 1,
    TimetoPickUp = 0.1,
}

BallPhysics.Dribble = {
    DribbleStartupTime = 0.05,
    DribbleTime = 0.1
}

BallPhysics.Tackle = {
    TackleTime = 0.1,
    TackleDistance = 5,
    TackleForce = 1000,
    Range = 5
}

BallPhysics.Rainbowflick = {
    UpForce = Vector3.new(0,70,0),
    FrontForce = 20,
    TimetoPickUp = 0.5
}

return BallPhysics