#include <sourcemod>
#include <cstrike>
#include <sdktools>
#pragma newdecls required
#pragma semicolon 1
public Plugin myinfo =
{
	name = "Round End Sound Random",
	author = "DavutHaxor",
	description = "Precaches all sounds from casualgomvp and plays a random one at the end of each round",
	version = "1.0.0"
};
ArrayList g_SoundList;
public void OnPluginStart()
{
	// Hook the round end event - only needs to be hooked once
	HookEvent("round_end", Event_RoundEnd);
	
	// Load sounds list for playing (loads once on plugin start)
	LoadSoundsList();
}
public void OnMapStart()
{
	// Precache and add to downloads table on each map start
	PrecacheSounds();
}
void LoadSoundsList()
{
	if (g_SoundList != null)
	{
		delete g_SoundList;
	}
	
	g_SoundList = new ArrayList(256);
	
	DirectoryListing dir = OpenDirectory("sound/casualgomvp");
	
	if (dir == null)
	{
		LogError("Failed to open sound/casualgomvp directory!");
		return;
	}
	
	char filename[256];
	FileType type;
	
	while (dir.GetNext(filename, sizeof(filename), type))
	{
		if (type == FileType_File)
		{
			// Only add audio files
			if (StrContains(filename, ".mp3") != -1 || StrContains(filename, ".wav") != -1)
			{
				g_SoundList.PushString(filename);
			}
		}
	}
	
	delete dir;
	
	LogMessage("Loaded %d sound(s) from casualgomvp directory", g_SoundList.Length);
}
void PrecacheSounds()
{
	if (g_SoundList == null || g_SoundList.Length == 0)
	{
		LogError("Sound list is empty!");
		return;
	}
	
	for (int i = 0; i < g_SoundList.Length; i++)
	{
		char soundFile[256];
		g_SoundList.GetString(i, soundFile, sizeof(soundFile));
		
		// Precache the sound
		char soundPath[256];
		FormatEx(soundPath, sizeof(soundPath), "casualgomvp/%s", soundFile);
		PrecacheSound(soundPath, true);
		
		// Add to downloads table
		char fullPath[256];
		FormatEx(fullPath, sizeof(fullPath), "sound/%s", soundPath);
		AddFileToDownloadsTable(fullPath);
	}
	
	LogMessage("Precached and added %d sound(s) to downloads table", g_SoundList.Length);
}
public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (g_SoundList == null || g_SoundList.Length == 0)
	{
		LogError("No sounds loaded!");
		return Plugin_Continue;
	}
	
	// Select a random sound
	int randomIndex = GetRandomInt(0, g_SoundList.Length - 1);
	char soundFile[256];
	g_SoundList.GetString(randomIndex, soundFile, sizeof(soundFile));
	
	// Play the random sound to all players
	char command[512];
	FormatEx(command, sizeof(command), "sm_play @all \"casualgomvp/%s\"", soundFile);
	ServerCommand(command);
	
	return Plugin_Continue;
}
