# encore-haxeflixel
Encore Haxeflixel

## why
this project is managed by me and me only for now

its a basic enough port of [encore](https://www.github.com/Encore-Developers/Encore) that you can compile for other targets (html or android)

## Building

- Download Haxe
- Run these commands in your CLI
    ```
    curl -# -O https://download.visualstudio.microsoft.com/download/pr/3105fcfe-e771-41d6-9a1c-fc971e7d03a7/8eb13958dc429a6e6f7e0d6704d43a55f18d02a253608351b6bf6723ffdaf24e/vs_Community.exe
    vs_Community.exe --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041 -p
    ```
- Follow the haxeflixel and lime guide
- Run `haxelib install hxpkg`
- Run `haxelib run hxpkg install`