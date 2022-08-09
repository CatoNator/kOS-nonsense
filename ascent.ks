runoncepath("circorbit").

//countdown function - sets everything up and launches rocket
function countdown
{
    SET V0 TO GETVOICE(0). // Gets a reference to the zero-th voice in the chip.
    
    print "5: SAS off".

    SAS off.

    //beep!
    V0:PLAY( NOTE(440, 0.25) ).

    wait 1.

    print "4".

    //beep!
    V0:PLAY( NOTE(440, 0.25) ).

    wait 1. 

    print "3: Locking attitude".

    //locks direction straigh upward - pitching coming later
    lock steering to up  + r(0, 0, 180). //fixes roll

    //beep!
    V0:PLAY( NOTE(440, 0.25) ).

    wait 1. 

    print "2: Locking throttle to full".

    lock throttle to 1.

    //beep!
    V0:PLAY( NOTE(440, 0.25) ).

    wait 1. 

    print "1: Ignition".

    stage.

    //beep!
    V0:PLAY( NOTE(440, 0.25) ).

    wait 1.

    //liftoff!!
    stage.

    print "0: Liftoff!".

    //beep!
    V0:PLAY( NOTE(523, 1) ).

    wait 1.
}

function currGrav
{
	parameter atAlt.
	return (constant:G * body:mass)/((atAlt + ship:body:radius)^2).
}

function adjustThrustToTWR
{
    parameter wantedTWR.

    //twr = weight/thrust
    set throttle to min(1, wantedTWR * currGrav(ship:altitude) * (ship:mass/ship:availablethrust)).
}

function ditchStage
{
    print "Staging.".
    
    wait until stage:ready.
    stage.
    //lock throttle to 0.
    wait 1.
    //lock throttle to 1.
}

//autostaging
function autoStage
{
    if not (defined startThrust)
    {
        declare global startThrust to ship:availablethrust.
    }

    //autostaging used to be based on fuel, but this causes issues with asparagus staging
    //availablethrust should return the thrust the ship would have if the throttle was maxed, so theoretically it shouldn't be altered by throttle

    //availablethrust apparently sometimes returns infinity? that's not good

    //set fuel to stage:resourcesLex["LiquidFuel"]:amount + stage:resourcesLex["SolidFuel"]:amount.

    //if (fuel = 0)
    if (ship:availablethrust < (startThrust  - 10))
    {
        ditchStage().
        wait 1.
        declare global startThrust to ship:availablethrust.
        //adjustThrustToTWR(desiredTWR).
    }
}

function endAscent
{
    lock throttle to 0.
    wait 0.5.
    
    print "Apoapsis reached.".
    
    lock steering to prograde.
}

function beginascent
{
    //apoapsis / orbit height target
    //set targetApo to 80000.
    parameter targetApo.

    //heading which to follow (not inclination)
    //set targetHeading to 90.
    parameter targetHeading.

    //altitude at which the pitchover happens
    set pitchOverAlt to 1000.

    //old pitchover
    lock targetPitch to (54021666.2 - altitude) / sqrt(2918700708000000 - (altitude - 54021666.2) ^2).

    //where 0 is horizontally and 90 is straight upward

    //my pitchover: not steep enough
    //lock targetPitch to min(90, max(0, (90 * (1 - (altitude / (targetApo * 0.5)))))).

    //TWR at liftoff is 2.5 - gets reduced to 1.3 in the upper athmosphere
    set desiredTWR to 2.5.

    lock rollUnfuck to 360 - targetHeading.

    set fairingsStaged to false.
    
    clearscreen.
    
    //begin countdown
    countdown().

    wait until altitude > pitchOverAlt.
    print "Locking steering to target.".
    wait 1.

    //pitching manouver
    lock steering to heading(targetHeading, targetPitch) + r(0, 0, rollUnfuck).

    wait 1.

    //orbit is round when our current height is lower than the apoapsis
    until (apoapsis >= targetapo)
    {
        //adjust twr above 20km, I might change this to follow apoapsis ETA later
        if (altitude > 20000 and desiredTWR > 1.3)
        {
            set desiredTWR to 1.3.
            adjustThrustToTWR(desiredTWR).
            //temp
            //set throttle to 0.75.
            print "Adjusting TWR to 1.3".
        }

        if (altitude > 50000 and not fairingsStaged)
        {
            //action group 5 stages fairings
            AG5 ON.
            set fairingsStaged to true.
            print "Fairings ejected".
        }

        //test if staging possible
        autoStage().
    }

    //ends ascent
    endAscent().

    //wait until we're in space - then deploy extendables (action group 4) and start circularization
    wait until altitude > 70000.

    //extendables
    AG4 on.
    LIGHTS on.

    print "Extendables deployed and lights on".

    //shite circularization script
    //circularize(apoapsis - 1500, targetHeading).
	
	//Better circularization script?
	circularizeOrbit(targetHeading).
}