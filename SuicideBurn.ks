function ShipHeight
{
    //the ship's center is where the control is, which causes issues when calculating burns
    //this function is supposed to calculate the separation from the landing legs to the control core
    //I'm not yet sure on how to compute this - to do
    return 2.
}

function DistanceToGround
{
    return altitude - body:geopositionof(ship:position):terrainheight - ShipHeight().
}

function StoppingDistance
{
    //g = G*((m1*m2)/r^2)
    local grav is constant:G * (body:mass / body:radius^2). //* ship:mass
    
    //a = f - g/m (where f is the ship's max thrust and g is the gravitational pull of the planetary body)
    local maxdeceleration is (ship:availablethrust - grav) / ship:mass.

    //s = v^2/2a

    //vertical speed isn't good - I think I need the vector acceleration
    local accmag is (v(0, ship:verticalspeed, 0) + v(ship:groundspeed, 0, 0)):mag.

    return accmag^2 / (2*maxdeceleration).
}

function PerformBurn
{
    //locks attitude to ground
    SAS off.

    lock steering to srfretrograde.

    lock throttle to 0.

    print "Steering locked - waiting for burn time".

    lock ratio to StoppingDistance() / DistanceToGround().

    //burn begins when stopping distance at full throttle is equal (or more) to distance to ground.
    //not the most efficient solution - stopping distance falls when you reduce velocity by firing the thrusters
    //which means that this tends to burn quite a bit of fuel hovering around 1/3rd of the throttle but fuck it, it works.
    wait until ratio > 1.

    print "Burning".

    lock throttle to ratio.

    //for some reason only when syntax has then - god only knows why
    when DistanceToGround() < 500 then
    {
        //bring out the gear
        gear on.
    }

    //uhhhh idk wait until we've stopped I guess
    wait until ship:verticalspeed > 0.

    lock throttle to 0.

    wait 2.

    unlock steering.

    print "The eagle has landed".
}

PerformBurn().