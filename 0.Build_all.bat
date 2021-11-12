call ./0.Build_locres.bat
cd /d ../UnrealPakSwitch
call "0.build all v11.bat"
cd /d "../Train Sim World TW Mod/latest"
xcopy *.pak "E:\Program Files (x86)\Steam\steamapps\common\Train Sim World 2\WindowsNoEditor\TS2Prototype\Content\DLC\" /Y
pause