
local language_table = dofile('scripts/languages.lua')

newoption {
    trigger     = 'to',
    value       = 'path',
    default     = 'build',
    description = 'Set the output location for the generated files',
}

workspace 'languages'
    kind 'SharedLib'
    entrypoint 'DllMain'

    configurations { 'Debug', 'Release' }
    platforms { 'Win32', 'Win64' }
    language 'C'
    characterset 'MBCS'
    symbols 'Off'

    flags {
        'StaticRuntime', 'NoManifest', 'MultiProcessorCompile',
        'NoIncrementalLink', 'LinkTimeOptimization',
    }

    location(_OPTIONS.to)
    targetdir 'bin/AkelFiles/Langs'
    objdir 'obj'

    resdefines { 'DLL_VERSION', }

    resincludedirs {
        'AkelEdit/Resources',
        'AkelFiles/Langs/Resources',
    }

    files {
        'AkelFiles/Langs/Module.c'
    }

    filter { 'platforms:Win32' }
        architecture 'x32'
        resdefines 'RC_VERSIONBIT=32'

    filter { 'platforms:Win64' }
        architecture 'x64'
        resdefines 'RC_VERSIONBIT=64'

    for name, id in pairs(language_table) do
        print(string.format('language name: %21s | id: %s', name, id))
        project(name)
            resdefines('RC_VERSIONLANGID=' .. id)
            files('AkelFiles/Langs/Resources/' .. name .. '.rc')
    end -- end for

