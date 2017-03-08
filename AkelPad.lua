
local language_table = dofile('scripts/languages.lua')
local plugin_table   = dofile('scripts/plugins.lua')

newaction {
    trigger = 'lang_list',
    description = 'Display Language Resource File list',
    execute = function ()
        for k, v in pairs(language_table) do
            print(string.format('language name: %21s | id: %s', k, v))
        end -- end for
    end -- end function
}

newoption {
    trigger     = 'to',
    value       = 'path',
    default     = 'build',
    description = 'Set the output location for the generated files',
}

newoption {
    trigger     = 'lang_name',
    value       = 'language',
    default     = 'English',
--    default     = 'Chinese (Simplified)',
    description = 'Set Language Resource File Name',
}

workspace 'AkelPad'
    configurations { 'Debug', 'Release' }
    platforms { 'Win32', 'Win64' }
    language 'C'
    characterset 'MBCS'

    flags { 'StaticRuntime', 'MultiProcessorCompile', 'NoManifest' }

    location(_OPTIONS.to)
    objdir 'obj'

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

project 'AkelPad'
    kind 'WindowedApp'
    entrypoint '_WinMain'
    targetdir 'bin'

    files {
        'AkelPad/*.h',
        'AkelPad/*.c',
        'AkelEdit/*.h',
        'AkelEdit/*.c',
        'AkelFiles/Langs/Resources/' .. _OPTIONS.lang_name .. '.rc',
    }

    defines {
        'AKELEDIT_STATICBUILD',
        'RC_VERSIONLANGID=' .. language_table[_OPTIONS.lang_name],
    }

    resdefines 'RC_EXEVERSION'

    includedirs {
        '.',
    }

    resincludedirs {
        'AkelEdit/Resources',
        'AkelFiles/Langs/Resources',
    }

    links {
        'comctl32',
        'imm32',
        'ole32',
        'oleaut32',
        'uuid',
        'version',
    }

project 'AkelAdmin'
    kind 'WindowedApp'
    entrypoint '_WinMain'
    targetdir 'bin/AkelFiles'

    files {
        'AkelAdmin/*.c',
        'AkelAdmin/Resources/AkelAdmin.rc'
    }

    includedirs {
        '.',
    }
    resincludedirs {
        'AkelAdmin/Resources',
    }

