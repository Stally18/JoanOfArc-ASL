//gametimer stops in menu, missiontimer resets to 0 in menu
//if you die both timers stop
//if you reset mission gametimer stops, then updates after loading; missiontimer resets then starts
//if you load a save not in a 'dead' state - timers dont stop, only update to save values after loading
//after finishing the mission both timers pause (and missiontimer resets)
//auto saves are created around ~2.5sec of ingame timer of the mission, and that causes gametimer to go nuts sometimes

state("JOAN", "Steam")
{

	// Module size: 6905856
	// Hash: 7A773B26CD67C37796DCF8057E5F654E

	int finaltimer :	0x657EC5;
	int missiontimer :	0x659181;
	int gametimer :		0x6596D0;
	
}

state("JOAN", "Akella")
{
	
	// Module size: 4915200
	// Hash: C6F149FC7DF4637B05A04B21CD94D55D 

	int finaltimer : 	0x472305;
	int missiontimer :	0x4735C1;
	int gametimer : 	0x473B10;
	
}

state("JOAN", "Retail")				// US 1.0
{
	// Module size: 6651904
	// Hash: 9F5994EB29B94085C1AB17C70E45AEFC 

	//string4 mission : 0x00086254;
	//string4 mission_too : 0x00086360;
	int finaltimer : 	0x0046EEBD;
	int missiontimer :	0x00470179;
	int gametimer : 	0x004706C8;
	
}

startup
{
	// to lower CPU usage and avoid race condition
	//refreshRate = 5;
	//vars.oldmission = "S0L1";
	
	Func<ProcessModuleWow64Safe, string> CalcModuleHash = (module) => {
		print("Calcuating hash of "+module.FileName);
		byte[] exeHashBytes = new byte[0];
		using (var sha = System.Security.Cryptography.MD5.Create())
		{
			using (var s = File.Open(module.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
			{
				exeHashBytes = sha.ComputeHash(s);
			}
		}
		var hash = exeHashBytes.Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
		return hash;
	};
	vars.CalcModuleHash = CalcModuleHash;
}

init
{
	//if (timer.IsGameTimePaused == true) timer.IsGameTimePaused = false;
	
	var module = modules.Single(x => String.Equals(x.ModuleName, "JOAN.exe", StringComparison.OrdinalIgnoreCase));
	var moduleSize = module.ModuleMemorySize;
	var hash = vars.CalcModuleHash(module);
	
	if (hash == "C6F149FC7DF4637B05A04B21CD94D55D")
	{
		// Module size: 4915200
		version = "Akella";
	}
	else if (hash == "9F5994EB29B94085C1AB17C70E45AEFC")
	{
		// Module size: 6651904
		version = "Retail";
	}
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
	if (current.gametimer != 0 && old.gametimer == 0)
		return true;
}

split
{
	// Split on campaign progress
	if (old.missiontimer == 0 && current.missiontimer < 2500 && current.missiontimer > 0)
		return true;
	// Split on game ending
	if (current.finaltimer > 0)
		return true;
}

reset 
{
	//return old.gametimer == current.gametimer && current.missiontimer == 0;
}

isLoading
{
	return old.gametimer == current.gametimer;
}

gameTime 
{
	// update IGT on starting every mission and when game ends
	if (current.missiontimer < 2500 || current.finaltimer > 0) 
		return TimeSpan.FromMilliseconds(current.gametimer);
}
