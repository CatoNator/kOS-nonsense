//script used to execute the launch
compile"0:/launch"  to "1:/launch.ks".

//liftoff
copypath("0:/ascent", "").
//compile "0:/ascent" to "1:/ascent.ks".

//orbit circularization
//copypath("0:/circorbit", "").
compile "0:/circorbit" to "1:/circorbit.ks".

//manouver execution
//copypath("0:/execManouver", "").
compile "0:/execManouver" to "1:/execManouver.ks".

//compile "0:/SuicideBurn" to "1:/SuicideBurn.ks".
copypath("0:/SuicideBurn", "").