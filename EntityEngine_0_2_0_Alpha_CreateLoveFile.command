# builds the entire current folder into a love file
# designed to be double clicked from mac OSX finder
# should be saved as a .command file with "sudo chmod +x" applied to it (allows it to execute)

# filename=EntityEngine_0_2_0_Alpha.love # would dump the file to the current directory
filename=~/Desktop/EntityEngine_0_2_0_Alpha.love # dump the file on the desktop

cd "`dirname "$0"`" # OSX hack that means the double clicked command file runs in the directory it is in
zip -9 -r $filename .
read # OSX hack allows waiting for a key press before command box is closed