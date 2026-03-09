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
	// Hook the round end event
	HookEvent("round_end", Event_RoundEnd);
	
	// Load and precache sounds from casualgomvp directory
	LoadAndPrecacheSounds();
}

void LoadAndPrecacheSounds()
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
				
				// Precache and add to downloads table
				char soundPath[256];
				FormatEx(soundPath, sizeof(soundPath), "casualgomvp/%s", filename);
				PrecacheSoundFile(soundPath);
			}
		}
	}
	
	delete dir;
	
	LogMessage("Loaded and precached %d sound(s) from casualgomvp directory", g_SoundList.Length);
}

void PrecacheSoundFile(const char[] soundFile)
{
	// Precache the sound
	PrecacheSound(soundFile, true);
	
	// Add to downloads table
	char fullPath[256];
	FormatEx(fullPath, sizeof(fullPath), "sound/%s", soundFile);
	AddFileToDownloadsTable(fullPath);
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
