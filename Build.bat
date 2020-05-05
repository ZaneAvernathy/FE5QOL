
@rem Change "QOL.sfc" to whatever name you want the output to have.
@.\TOOLS\superfamiconv.exe tiles -i .\BurstTiles.png -d .\BurstTiles.4bpp -B 4 -R -D -F
@.\TOOLS\superfamiconv.exe tiles -i .\RangeTiles.png -d .\RangeTiles.4bpp -B 4 -R -D -F
@.\TOOLS\superfamiconv.exe map -i .\BurstStyles.png -p .\BurstPlayer.pal -t .\BurstTiles.4bpp -d .\BurstStyles.bin -B 4
@.\TOOLS\superfamiconv.exe tiles -i .\SystemIcons.png -d .\SystemIcons.4bpp -B 4 -R -D -F
@.\TOOLS\64tass.exe -f -o "QOL.sfc" QOLInstaller.asm --vice-labels -l "QOL.cpu.sym"
@python .\TOOLS\fix_sym.py "QOL.cpu.sym"
@pause