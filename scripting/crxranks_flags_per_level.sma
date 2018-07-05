#include <amxmodx>
#include <amxmisc>
#include <crxranks>

new Trie:g_tFlags

public plugin_init()
{
	register_plugin("CRXRanks: Flags Per Level", "1.0", "OciXCrom")
	g_tFlags = TrieCreate()
	ReadFile()
}

public plugin_end()
	TrieDestroy(g_tFlags)
	
ReadFile()
{
	new szConfigsName[256], szFilename[256]
	get_configsdir(szConfigsName, charsmax(szConfigsName))
	formatex(szFilename, charsmax(szFilename), "%s/RankSystemFlags.ini", szConfigsName)
	
	new iFilePointer = fopen(szFilename, "rt")
	
	if(iFilePointer)
	{
		new szData[64], szValue[32], szMap[32], szKey[32], bool:bRead = true, iSize
		get_mapname(szMap, charsmax(szMap))
		
		while(!feof(iFilePointer))
		{
			fgets(iFilePointer, szData, charsmax(szData))
			trim(szData)
			
			switch(szData[0])
			{
				case EOS, '#', ';': continue
				case '-':
				{
					iSize = strlen(szData)
					
					if(szData[iSize - 1] == '-')
					{
						szData[0] = ' '
						szData[iSize - 1] = ' '
						trim(szData)
						
						if(contain(szData, "*") != -1)
						{
							strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '*')
							copy(szValue, strlen(szKey), szMap)
							bRead = equal(szValue, szKey) ? true : false
						}
						else
						{
							static const szAll[] = "#all"
							bRead = equal(szData, szAll) || equali(szData, szMap)
						}
					}
					else continue
				}
				default:
				{
					if(!bRead)
						continue
						
					strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
					trim(szKey); trim(szValue)
							
					if(!szValue[0])
						continue
						
					TrieSetCell(g_tFlags, szKey, read_flags(szValue))
					log_amx("%s = %i", szKey, read_flags(szValue))
				}
			}
		}
		
		fclose(iFilePointer)
	}
}

public crxranks_user_level_updated(id, iLevel, bool:bLevelUp)
{
	client_print(id, print_chat, "start")
	if(!bLevelUp)
		return
	client_print(id, print_chat, "after levelup")	
	for(new szI[8], iUserFlags = get_user_flags(id), iLevelFlags, i; i <= iLevel; i++)
	{
		num_to_str(i, szI, charsmax(szI))
		
		if(TrieGetCell(g_tFlags, szI, iLevelFlags))
		{
			if((iUserFlags & iLevelFlags) != iLevelFlags)
				set_user_flags(id, iLevelFlags)
		}
	}
}