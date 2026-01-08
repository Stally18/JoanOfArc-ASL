state("JOAN")	
{
	
	long gametimer : 0x004706C8;
	long missiontimer : 0x00470179;
	
}

startup
{
	// to lower CPU usage
	refreshRate = 5;
	//vars.oldmission = "S0L1";
}

init
{
	//if (timer.IsGameTimePaused == true) timer.IsGameTimePaused = false;
}

exit
{
	//timer.IsGameTimePaused = true;
}

update
{

}

start
{
	if (current.missiontimer != 0 && old.missiontimer == 0)
		return true;
}

split
{
	if (old.missiontimer > current.missiontimer && current.missiontimer < 2500)
		return true;
}

reset 
{
	// Won't do because same happens when you progress through missions
	//return old.gametimer == current.gametimer && current.missiontimer == 0;
}

isLoading
{
	return old.gametimer == current.gametimer;
}

gameTime 
{
	// Update IGT timer after every mission complete. Might try constant update in future
	if (current.missiontimer < 2500) 
		return TimeSpan.FromMilliseconds(current.gametimer);
}


