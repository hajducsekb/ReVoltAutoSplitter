state ("rvgl")
{
	int RaceTime : 0xF9E89C; //Your current lap time
	int Loading : 0xE930DC; //Bool, shows if the game is loading
	int stuntStars : 0x80F750; //Counts the stars taken from stunt arena
	int championshipLapCounter: 0xEB1978; //Indicated the max laps on championships
	int lapCounter: 0xF9E898; //Indicates the number of laps you completed. Starts from 0
	byte folder: 0x80C11C; //Indicates if the user is in main menu
	byte Nhood1: 0x232998; // These below are definitions for the progress table for each map.
	byte SM2: 0x232A0C;
	byte MS2: 0x232A80;
	byte BG: 0x232AF4;
	byte Roof: 0x232B68;
	byte TW1: 0x232BDC;
	byte GT1: 0x232C50;
	byte TW2: 0x232CC4;
	byte Nhood2: 0x232D38;
	byte TT1: 0x232DAC;
	byte MS1: 0x232E20;
	byte SM1: 0x232E94;
	byte GT2: 0x232F08;
	byte TT2: 0x232F7C;
}
startup
{
	settings.Add("AllCups", true, "All Cups");
	settings.Add("StuntArena", false, "Stunt Arena");
	settings.Add("100%", false, "100%");
}
init
{
	vars.split=0; //Important for knowing where are you currently in the run to avoid double splitting at the end of cups on 100%.
	//Setting up the check criteria for 100% (comparing each row in the progress table by reffering it with its name):
	vars.mapNames = new List<string> { "Nhood1", "SM2", "MS2", "BG", "Roof", "TW1", "GT1", "TW2", "Nhood2", "TT1", "MS1", "SM1", "GT2", "TT2" };
}
start
{
	if(current.Loading==0 && old.Loading==1 && current.folder!=0) //Checks if any type of race loaded in
	{
		vars.split=0;
		return true;
	}
}
update
{
}
split
{
	if(settings["100%"])
	{
		if(current.Nhood1>32 && old.Nhood1<32 || current.TW1>32 && old.TW1<32 || current.Nhood2>32 && old.Nhood2<32 || current.SM1>32 && old.SM1<32) //Checks if you're not at the and of any cup(avoids double splitting)
		{}//does nothing
		else
		{
			var c = current as IDictionary<String, Object>;
			var o = old as IDictionary<String, Object>;
			foreach(string map in vars.mapNames)
			{    
				if((byte) c[map]>(byte) o[map]) //Splits if the progress table gets added a progress
				{
					vars.split+=1;
					return true;
				}
			}
		}
		if(current.stuntStars==20 && old.stuntStars==19)
		{
			vars.split+=1;
			return true;
		}
	}
	if(settings["100%"] || settings["AllCups"])
	{
		if(current.lapCounter==current.championshipLapCounter && current.lapCounter!=old.lapCounter) //Race has been finished, the right condition is to prevent it from triggering multiple times
		{
			if(settings["100%"])
			{	
				vars.split+=1;
				return true;
			}
			if(settings["AllCups"])
			{
				vars.split+=1;
				return true;
			}
		}
	}
	if(settings["StuntArena"])
	{
		if(current.stuntStars==20)
		{
			return true;
		}
	}
}
isLoading
{
	if(current.Loading==1)
	{
		return true;
	}
	else
	{
		return false;
	}
}
reset
{
	if(settings["100%"] || settings["AllCups"])
	{
		if(settings["AllCups"])
		{
			if(current.folder==0)
			{
				if(vars.split!=4 && vars.split!=8 && vars.split!=12)
				{
					return true;
				}
			}
		}
		var c = current as IDictionary<String, Object>;
		var o = old as IDictionary<String, Object>;
        foreach(string map in vars.mapNames)
        {    
			if((byte) c[map]<(byte) o[map]) //Resets if the progress table gets reset
			{
				return true;
			}
        }
	}
	if(settings["StuntArena"])
	{
		if(current.Loading==1) //Simple check for quitting the race
		{
			return true;
		}
	}
}
