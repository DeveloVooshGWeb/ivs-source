#!/bin/sh
sudo apt-get install libgl1-mesa-dev libglu1-mesa-dev g++ g++-multilib gcc-multilib libasound2-dev libx11-dev libxext-dev libxi-dev libxrandr-dev libxinerama-dev
sudo apt install nodejs
sudo apt install npm
npm install lix -g
lix scope create
lix install haxe 4.1.5
./fnfsetup.sh
