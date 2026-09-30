@echo off
for /R %%f in (*.ogg) do (
    ffmpeg -y -i "%%f" "%%~dpnf.wav"
    if exist "%%~dpnf.wav" del "%%f"
)