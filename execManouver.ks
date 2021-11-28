function vISP
{
    list engines in engineList.
    set sumOne to 0.
    set sumeTwo to 0.

    for (eng in engineList)
    {
        if (eng:ignition
        {
            set sumOne to sumOne + eng:availablethrust.
            set sumTwo to sumTwo + eng:availablethrust / eng:ISP.
        })
    }

    if (sumTwo > 0)
    {
        return sumOne /sumTwo.
    }
    else
    {
        return -1.
    }
}

//calculate burn time; for some reason kOS doesn't let you read the burn time from the node info.
function burnTime
{
    parameter mnode.

    set dV to mnode:burnvector:mag.

    //error handling: fuck that, we're playing KSP!
    if (vISP() < 0)
    {
        print "No active engines for manouver execution!".
        wait until (vISP() > 0).
    }

    set finalMass to ship:mass / (constant:E^(delV/(vISP()*constant:g0))).
    set startAcc to ship:availablethrust / ship:mass.
    set finalAcc to ship:availablethrust / finalMass.
    return 2*delV / (startAcc+finalAcc).
}

function calculateStartTIme
{
    parameter mnode.

    //calculate start time based on mnode

    //burn starts at ETA to node - burn time / 2; recommended time to start any burn
    return return time:seconds + mnode:eta - burnTime(mnode)/2.
}

function startBurn
{
    parameter stTime.

    wait until time:seconds > stTime - 3.

    print "3".
    wait 1.
    print "2".
    wait 1.
    print "1".
    wait 1.

    lock throttle to 1.

    print "Starting burn".
}

function lockHeading
{
    parameter mnode.

    lock steering to mnode:burnvector.
    
    print "Locking steering to manouver node".
}

function reduceThrottle
{
    parameter mnode.
    parameter startReduceTime.

    wait until burnTime(mnode) < startReduceTime.

    print "Reducing throttle".

    set reduceTime to startReduceTime*2/0.9.

    set reductionStartTime to time:seconds.
    set reductionStopTime to time:seconds + reduceTime.

    set scale to 0.1^/1/reducetime).

    lock throttle to scale^(time:seconds - startTime).

    wait until time:seconds > stopTime.

    lock throttle to 0.1.
}

function manouverComplete
{
    parameter mnode.
    parameter startVec.

    if (vang(mnode:burnvector, startVec) > 5)
    {
        return true.
    }
    else
    {
        return false.
    }
}

function endBurn
{
    parameter mnode.
    parameter startVec.

    wait until manouverComplete(mnode, startVec).

    print "Ending burn".

    lock throttle to 0.

    unlock steering.
    remove mnode.
    wait 1.
}

function execManNode
{
    if hasnode
    {
        SAS off.
        declare local mnode to nextnode.

        set startTime to calculateStartTime(mnode).
        set startVector to mnode:burnvector.

        set startReduceTime to 2.

        //performing burn
        lockHeading(mnode).
        startBurn(mnode, startTime).
        reduceThrottle(mnode).
        endBurn(mnode, startVector).

        print "Manouver perform completed".

        wait 2.
    }
    else
    {
        print "No manouver node in flight plan".
    }
}

execManNode().