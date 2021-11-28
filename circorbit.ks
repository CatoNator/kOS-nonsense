runoncepath("ascent").

function planOrbit
{

}

//in the future this will just plot a circularization burn and then use a manouver node execution script to perform the burn

function circularizeOrbit
{
    parameter targetPeriapsis.
    parameter targetHeading.

    //plan orbit based on given params
    planOrbit().

    //execute manouver
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
    until (periapsis > wantedPeriapsisHeight or apoapsis > altitude + 1000)
    {
        autoStage().
    }

    set throttle to 0.

    wait 1.
    print "Circularization completed.".

}