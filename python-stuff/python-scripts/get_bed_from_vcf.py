from unicodedata import name
import pandas as pd

def get_panda(file_path):
    HEADER = ["CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", file_path]
    return pd.read_table(file_path, sep="\t",comment="#", header=None, names=HEADER)

def merge_vcfs(file_paths, output_file):
    frames = [get_panda(path) for path in file_paths]
    header = []
    with open(file_paths[0], "r") as file:
        for line in file:
            if line[0]=="#":
                header.append(line)
    result = frames.pop(0)
    while len(frames)>0:
        name = frames[0].columns[-1]
        result=pd.merge(result,frames.pop(0)[["CHROM", "POS", "REF", "ALT", name]], on=["CHROM", "POS", "REF", "ALT"], how="outer", suffixes=(None, "???"))
    with open(output_file, "w") as file:
        file.writelines(header)
        result.to_csv(file, sep="\t", index = None, na_rep="NA")
