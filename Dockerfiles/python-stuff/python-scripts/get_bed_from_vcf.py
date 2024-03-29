#!/usr/bin/env python3
import pandas as pd
import sys
order = ["chr1",
    "chr2",
    "chr3",
    "chr4",
    "chr5",
    "chr6",
    "chr7",
    "chrX",
    "chr8",
    "chr9",
    "chr10",
    "chr11",
    "chr12",
    "chr13",
    "chr14",
    "chr15",
    "chr16",
    "chr17",
    "chr18",
    "chr20",
    "chrY",
    "chr19",
    "chr22",
    "chr21",
    "chr6_ssto_hap7",
    "chr6_mcf_hap5",
    "chr6_cox_hap2",
    "chr6_mann_hap4",
    "chr6_apd_hap1",
    "chr6_qbl_hap6",
    "chr6_dbb_hap3",
    "chr17_ctg5_hap1",
    "chr4_ctg9_hap1",
    "chr1_gl000192_random",
    "chrUn_gl000225",
    "chr4_gl000194_random",
    "chr4_gl000193_random",
    "chr9_gl000200_random",
    "chrUn_gl000222",
    "chrUn_gl000212",
    "chr7_gl000195_random",
    "chrUn_gl000223",
    "chrUn_gl000224",
    "chrUn_gl000219",
    "chr17_gl000205_random",
    "chrUn_gl000215",
    "chrUn_gl000216",
    "chrUn_gl000217",
    "chr9_gl000199_random",
    "chrUn_gl000211",
    "chrUn_gl000213",
    "chrUn_gl000220",
    "chrUn_gl000218",
    "chr19_gl000209_random",
    "chrUn_gl000221",
    "chrUn_gl000214",
    "chrUn_gl000228",
    "chrUn_gl000227",
    "chr1_gl000191_random",
    "chr19_gl000208_random",
    "chr9_gl000198_random",
    "chr17_gl000204_random",
    "chrUn_gl000233",
    "chrUn_gl000237",
    "chrUn_gl000230",
    "chrUn_gl000242",
    "chrUn_gl000243",
    "chrUn_gl000241",
    "chrUn_gl000236",
    "chrUn_gl000240",
    "chr17_gl000206_random",
    "chrUn_gl000232",
    "chrUn_gl000234",
    "chr11_gl000202_random",
    "chrUn_gl000238",
    "chrUn_gl000244",
    "chrUn_gl000248",
    "chr8_gl000196_random",
    "chrUn_gl000249",
    "chrUn_gl000246",
    "chr17_gl000203_random",
    "chr8_gl000197_random",
    "chrUn_gl000245",
    "chrUn_gl000247",
    "chr9_gl000201_random",
    "chrUn_gl000235",
    "chrUn_gl000239",
    "chr21_gl000210_random",
    "chrUn_gl000231",
    "chrUn_gl000229",
    "chrM",
    "chrUn_gl000226",
    "chr18_gl000207_random"]

def get_panda(file_path):
    HEADER = ["CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", file_path]
    return pd.read_table(file_path, sep="\t",comment="#", header=None, names=HEADER)

def merge_vcfs(file_paths, output_file, output_bedfile):
    """Merge INFO-less vcf files.

    Args:
        file_paths (list(paths)): All the input files
        output_file (path): The output vcf
    """
    frames = [get_panda(path) for path in file_paths]
    NA_STRING=("NA:"*len(frames[0]["FORMAT"][0].split(":")))[:-1]
    header = []
    for file_path in file_paths:
            with open(file_path, "r") as file:
                for line in file:
                    if line[0]=="#" and not line in header and line[:34]!="#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\t":
                        header.append(line)
    
    result = frames.pop(0)
    # header.append("#")
    while len(frames)>0:
        name = frames[0].columns[-1]
        result=pd.merge(result,frames.pop(0)[["CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", name]], on=["CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT"], how="outer", suffixes=(None, "???"))
    
    # Here we sort first by chromosome('s actual location) then by position.
    result=pd.concat((result,(result["CHROM"].map(lambda x: order.index(x) if x in order else hash(x))).rename("CHROM_ORDER")), axis=1)
    result.sort_values(["CHROM_ORDER", "POS"], inplace=True)
    result.drop("CHROM_ORDER", axis=1, inplace=True)

    with open(output_file, "w") as file:
        file.writelines(header)
        result.to_csv(file, sep="\t", index = None, na_rep=NA_STRING)
    bed=pd.concat([result["CHROM"], result["POS"]-1, result["POS"]], axis=1)
    with open(output_bedfile, "w") as file:
        bed.to_csv(file, sep="\t", index = None, header=None)

if __name__=="__main__":
    if len(sys.argv)>3:
        # THIS VCF DOESN'T HAVE A # IN FRONT OF THE CHROM ... LINE!!!
        merge_vcfs(sys.argv[1:-2], sys.argv[-2], sys.argv[-1])
    else:
        print("USAGE: [vcf1] [vcf2] ... [output_vcf] [output_bed]", file=sys.stderr)