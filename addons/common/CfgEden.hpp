class ctrlToolbox;

class Cfg3DEN {
    class Attributes {
        class Default;
        class Title: Default {
            class Controls {
                class Title;
            };
        };
        class GVAR(fireTeamControl): Title {
            attributeLoad = "(_this controlsGroupCtrl 100) lbsetcursel (['MAIN','RED','GREEN','BLUE','YELLOW'] find (toUpper _value));";
            attributeSave = "['MAIN','RED','GREEN','BLUE','YELLOW'] select (missionnamespace getvariable ['cba_fireTeam_temp',0])";
            class Controls: Controls {
                class Title: Title{};
                class Value: ctrlToolbox {
                    idc = 100;
                    style = "0x02";
                    x = "48 * (pixelW * 1.25 * 4)";
                    w = "82 * (pixelW * 1.25 * 4)";
                    h = "5 * (pixelH * 1.25 * 4)";
                    rows = 1;
                    columns = 5;
                    strings[] = {"$STR_TEAM_MAIN","$STR_TEAM_RED","$STR_TEAM_GREEN","$STR_TEAM_BLUE","$STR_TEAM_YELLOW"};
                    onToolboxSelChanged = "missionnamespace setvariable ['cba_fireTeam_temp',_this select 1];";
                };
            };
        };
    };
    class Object {
        class AttributeCategories {
            class ADDON {
                displayName = "CBA";  
                collapsed = 1;                
                class Attributes {
                    class GVAR(setFireteam) {
                        property = QGVAR(setFireteam);
                        control = QGVAR(fireTeamControl);
                        displayName = "$STR_A3_CfgChainOfCommand_Sizes_FireTeam_name";
                        expression = "if (_value != 'MAIN') then { _this setVariable ['cba_common_synchedTeam', _value, true]};";
                        defaultValue = "MAIN";
                        condition = "objectBrain";
                    };
                };
            };
        };
    };
};
