// Uncomment this for testing in singleplayer
// #define DEBUG_MODE

class Extended_DisplayLoad_EventHandlers {
    class RscDisplayMPInterrupt {
        OCAP = "call OCAP_client_fnc_onPause";
    };

#ifdef DEBUG_MODE
    class RscDisplayInterrupt  {
        OCAP = "call OCAP_client_fnc_onPause";
    };
#endif
};
