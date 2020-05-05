
# FE5 Quality of Life

This is a set of quality of life additions for Fire Emblem: Thracia 776.

Currently, the list of features is:

* Guard AI display
* Movement speedup
* Swap animation mode
* Talk display
* Equipped item preview
* HP bars

See `QOLConfiguration.txt` for a description of each feature.

## Usage

### Requirements

In the `TOOLS` folder, place:

* [**SuperFamiconv**](https://github.com/Optiroc/SuperFamiconv)
* [**64tass**](https://sourceforge.net/projects/tass64/)
* [**VoltEdge**](https://github.com/ZaneAvernathy/VoltEdge)

You'll also want to have some recent version of Python 3 installed and have your PATH configured to use it.

### Usage

With all of the requirements met, edit `QOLConfiguration.txt` to select the ROM to apply changes to, the offset of freespace to put the code, and which QOL features to apply. Then, you can edit the `Build.bat` file to change the output ROM's name, if you desire. Finally, run `Build.bat` to assemble.

Alternatively, you could add the component source files for each QOL feature into your own buildfile (see `QOLInstaller.asm`).

