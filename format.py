import os

def deleteSpace(filepath):
    if not filepath.endswith(".swift"):
        return
    output = ""
    with open(filepath, "r") as f:
        lines = f.readlines()
        for line in lines:
            if len(line) != 0 and len(line) == line.count(" ") + 1:
                line = line[-1:]
            output += line
    with open(filepath, "w") as f:
        f.write(output)

def run(path):
    filelist = os.listdir(path)
    for file in filelist:
        fullPath = os.path.join(path, file)
        if os.path.isdir(fullPath):
            run(fullPath)
        else:
            deleteSpace(fullPath)

basePath = os.path.dirname(os.path.realpath(__file__))
run(os.path.join(basePath, "StickerCustom", "StickerCustom"))