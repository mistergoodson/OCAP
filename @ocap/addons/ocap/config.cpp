#include "script_component.hpp"
class CfgPatches
{
	class OCAP
	{
		name = "OCAP";
		author = "MisterGoodson";
		units[] = {};
		weapons[] = {};
    	requiredAddons[] = {"cba_main"};
    	VERSION_CONFIG;
	};
};

class CfgFunctions
{
	class OCAP
	{
		class null
		{
			file = "\x\ocap\addons\main\functions";
			class init {postInit = 1;};
			class exportData {};
			class callExtension {};
			class captureFrame {};
			class addEventHandlers;
			class log;
			class eh_killed;
			class eh_fired;
			class eh_hit;
			class eh_disconnected;
			class eh_connected;
    		class handleProjectiles;
		};
	};
};
