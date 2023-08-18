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

    //Temp...
    //stage.

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

    if (ship:availablethrust < (startThrust  - 10))
    {
        ditchStage().
        wait 1.
        declare global startThrust to ship:availablethrust.
    }
}

function beginascent
{
    //apoapsis / orbit height target
    //set targetApo to 80000.
    parameter targetApo.

    //heading which to follow (not inclination)
    //set targetHeading to 90.
    parameter targetHeading.

    //TWR at liftoff is 2.5 - gets reduced to 1.3 in the upper athmosphere
    set desiredTWR to 2.5.

    lock rollUnfuck to 360 - targetHeading.

    set fairingsStaged to false.
    
    clearscreen.
    
    //begin countdown
    countdown().

    wait 1.

    //orbit is round when our current height is lower than the apoapsis
    until (apoapsis >= targetapo)
    {
        //test if staging possible
        autoStage().
    }
}