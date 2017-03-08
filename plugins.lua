
local plugin_table   = dofile('scripts/plugins.lua')

newoption {
    trigger     = 'to',
    value       = 'path',
    default     = 'build',
    description = 'Set the output location for the generated files',
}

workspace 'plugins'
    kind 'SharedLib'
    entrypoint 'DllMain'
    targetdir 'bin/AkelFiles/Plugs'

    configurations { 'Debug', 'Release' }
    platforms { 'Win32', 'Win64' }
    language 'C'
    characterset 'MBCS'

    flags { 'StaticRuntime', 'MultiProcessorCompile', 'NoManifest' }

    location(_OPTIONS.to)
    objdir 'obj'
    implibdir 'lib'

    filter { 'platforms:Win32' }
        architecture 'x32'
        defines 'RC_VERSIONBIT=32'

    filter { 'platforms:Win64' }
        architecture 'x64'
        defines 'RC_VERSIONBIT=64'

    filter 'action:vs*'
        disablewarnings {
            '4996', -- 4996 - same as define _CRT_SECURE_NO_WARNINGS
            '4100', '4201', '4204', '4255', '4310', '4619',
            '4668', '4701', '4706', '4711', '4820', '4826',
        }

    filter 'configurations:Debug'
        symbols 'On'
        symbolspath '$(OutDir)$(TargetName).pdb'
        optimize 'Debug'


    filter { 'configurations:Debug', 'action:vs2015 or vs2017' }
        -- vs2015 and later version StaticRuntime will link libvcruntimed and libucrtd
        links {
            'libvcruntimed',
            'libucrtd',
        }

    filter 'configurations:Release'
        symbols 'Off'
        optimize 'Full'

    for _, name in ipairs(plugin_table) do
        project(name)
            files {
                'AkelFiles/Plugs/' .. name .. '/Source/*.h',
                'AkelFiles/Plugs/' .. name .. '/Source/*.c',
                'AkelFiles/Plugs/' .. name .. '/Source/Resources/' .. name .. '.rc',
            }
            links {
                'comctl32',
                'winmm',
            }

        -- copy plugs files
        local p = os.getcwd() .. '/AkelFiles/Plugs/'.. name .. '/Plugs/';
        if os.isdir(p) then
            postbuildcommands {
                '{COPY} ' .. p ..  ' %{cfg.buildtarget.directory}/'
            }
        end -- end if
    end -- end for

    project 'Scripts'
        defines { 'SCRIPTS_MAXHANDLE=0x7FFFFFFF' }

        -- get Scripts.idl's absolute path
        local p = os.getcwd() .. '/AkelFiles/Plugs/Scripts/Source/'
        -- get scripts.idl's relative path
        p = path.getrelative(os.getcwd() .. '/' .. _OPTIONS.to, p)

        prebuildmessage 'generating tbl file'
        filter { 'platforms:Win32' }
            prebuildcommands {
                string.format('midl /win32 /mktyplib203 /tlb %s/Scripts.tlb %s/Scripts.idl', p, p)
            }
        filter { 'platforms:Win64' }
            prebuildcommands {
                string.format('midl /x64 /mktyplib203 /tlb %s/Scripts.tlb %s/Scripts.idl', p, p),
                string.format('ml64 /c %s/ISystemFunction64.asm', p),
            }
            links { 'ISystemFunction64.obj' }


