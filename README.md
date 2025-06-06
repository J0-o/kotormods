# Knights of the Old Republic MODS & FIXES
## BOTH
### Texture Conflict Checker
Texture conflict checker for K1 and K2. Place in your game directory and open it. It will list all conflicting textures, in the override folder, and allow you to choose which version to keep. Unwanted textures are moved to a texture_duplicates folder and can be restored through the tool. 
## KOTOR 1
### Resolution Patcher
Alternative to UNIWS patcher. Enables for widescreen resolutions and borderless fullscreen.
Place .bat script into you swkotor directory and run it. It will ask for your prefered resolution and it will patch swkotor.exe and edit the swkotor.ini.
## KOTOR 2
### C3FD Patcher
Restores fog and reflections which were broken in the Aspyr update. Works with both Steam and GOG versions. Only works on an unmodified swkotor2.exe. WIndows systems only.
Included EXE Patches:
- Fog Fix
- Reflections Fix
- 4GB Patch
- Subtle Color Shift
- Music Volume During Dialogue Fix

How to use: 
Place C3-FD_patcher.exe into your kotor2 game directory and run. It will patch your game exe with the fixes listed above.
It will check if you have an unmodified steam or gog version of the latest (Aspyr) patch, otherwise it wont run.
It will also make a backup of your original swkotor2.exe.

How this was made:
- The fog shading was just covered up when the latest version was released. I was able to send that data to the new Fracture shaders and apply fog coloring. It checks if the fog color is set to black and if not then it applies fog. Modules that don't use fog have a default fog color of black, Duxn and Dantoonie use a grayish color.
- The shader for when both a lightmap and a cubemap is applied, to the same model, had a typo. Cubemap was labeled as a '2D' instead of 'CUBE'. Easy fix.
Luckily the shaders are a plain text string, in the exe, and can be modified with a hex editor. The only issue is that the character length needs to be the same or smaller. The only way to get more data in the shader is to remove extra spaces/linebreaks and to shorten variables to single characters.
- The music was lowered so much during dialogue that it was almost non existent. I was able to find the functions for calling volume control, using ghidra. The call was made only 3 times and from there it was process of elimination. Ultimately disabling a variable change if in dialogue, before the first volume change call, worked.

Special Thanks:
HappyFunTimes101 - ShaderOverride - I could not have done this without this tool. This made sorting out and identifying the shader data much easier. I probably wouldn't have even attempted or known where to look if this didn't exist.
