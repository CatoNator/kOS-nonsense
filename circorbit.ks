runoncepath("ascent").

function planOrbit
{

}

//in the future this will just plot a circularization burn and then use a manouver node execution script to perform the burn

function circularizeOrbit
{
    parameter wantedHeading.
	
	print "Slightly less scuffed circularization begins".
	
	//epic prograde moment
	set hUnitVector to heading(wantedHeading, 0).
	
	//Calculate circular orbit velocity
	
	//v = sqrt(GM(2/r - 1/a))
	
	//semi-major axis
	set sma to (apoapsis + periapsis) / 2.
	
	//Scalar, need horizontal vector
	set desiredVelocity to SQRT(constant:G * KERBIN:MASS * (2/apoapsis - 1/sma)).
	
	set v1 to SHIP:VELOCITY:ORBIT.
	
	set v2 to V(desiredVelocity, desiredVelocity, desiredVelocity) * hUnitVector.
	
	set additionalVelocity to v2 - v1.
	
	ADD NODE(SHIP:OBT:ETA:APOAPSIS,  additionalVelocity:X, additionalVelocity:Y, additionalVelocity:Z).
	
	print "Plotted maneuver".
	
	runpath("execManouver").
}

//temp circularization...
function circularize
{
    parameter wantedPeriapsisHeight.

    parameter wantedHeading.
    
    //scuffed circularization script

    print "Scuffed circularization begins".

    wait until verticalspeed < 25.

    //epic prograde moment
    lock steering to heading(wantedHeading, 0).

    print "Heading locked".
    wait 0.5.

    print "Engine firing".
    lock throttle to 0.66.

    //if apoapsis is above us, it prrrrrrobably means that the orbit has turned around
    until (periapsis > wantedPeriapsisHeight or periapsis >= (apoapsis - 2000))
    {
        autoStage().
    }

    set throttle to 0.

    wait 1.
    print "Circularization completed.".

}