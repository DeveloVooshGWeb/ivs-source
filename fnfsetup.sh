#!/bin/sh
lix scope create
lix use haxe 4.1.5
lix install haxelib:neko
lix install haxelib:lime
lix install haxelib:lime-samples
lix install haxelib:openfl
lix install haxelib:openfl-samples
lix install haxelib:flixel
lix install haxelib:flixel-ui
lix install haxelib:flixel-demos
lix install haxelib:flixel-tools
lix install haxelib:flixel-templates
lix install haxelib:hscript
lix install haxelib:newgrounds
lix install git:https://github.com/larsiusprime/polymod.git as polymod
lix install git:https://github.com/Aidan63/linc_discord-rpc as discord_rpc
lix install git:https://github.com/HaxeFlixel/flixel-addons as flixel-addons
lix install haxelib:actuate
lix install haxelib:format
lix install haxelib:layout
lix install haxelib:box2d
lix install haxelib:assetsmanager
lix install haxelib:beanhx
lix install haxelib:compiletime
lix install haxelib:detox
lix install haxelib:hxcpp
lix install haxelib:hxssl
lix install haxelib:mconsole
lix install haxelib:mcover
lix install haxelib:munit
lix install haxelib:mlib
lix install haxelib:selecthxml
lix install haxelib:systools
lix install haxelib:exception
lix install haxelib:jquery
lix install haxelib:jQueryExtern
haxelib run lime setup flixel --always
haxelib run lime setup --always
haxelib run flixel-tools setup --always
haxelib run lime setup flixel --always
haxelib run lime setup --always
haxelib run flixel-tools setup --always
