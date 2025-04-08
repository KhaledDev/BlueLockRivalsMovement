local BallPhysics = {}

BallPhysics.Shooting = {
    UpForce = Vector3.new(0,30,0),
    Force = 150,
    Bouncyness = 1,
    TimetoPickUp = 0.1,
}

BallPhysics.Passing = {
    UpForce = Vector3.new(0,10,0),
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
    TackleDistance = 5,
    TackleForce = 50,
    Range = 5
}

BallPhysics.Rainbowflick = {
    UpForce = Vector3.new(0,60,0),
    FrontForce = 20,
    TimetoPickUp = 0.5
}

return BallPhysics