runoncepath("ascent").

function planOrbit
{

}

//in the future this will just plot a circularization burn and then use a manouver node execution script to perform the burn

function circularizeOrbit
{
    parameter wantedApoapsis.
	
	print "Slightly less scuffed circularization begins".
	
	local bm is BODY:MU.
	local br is BODY:RADIUS.
	local ra is br + apoapsis.
	
	//Velocity for circularization
	local srfcGrav is (bm / br^2).
	local v1 is (br * SQRT(srfcGrav / (br + wantedApoapsis))).
	
	//Velocity at apoapsis
	local v2 is SQRT(bm * ((2 / ra) - (1 / SHIP:ORBIT:SEMIMAJORAXIS))).
	
	//dV = tV - cV
	local deltaV is v1 - v2.
	
	ADD NODE(TIME:SECONDS + ETA:APOAPSIS, 0, 0, deltaV).
	
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

    lock throttle to 0.

    wait 1.
    print "Circularization completed.".

}