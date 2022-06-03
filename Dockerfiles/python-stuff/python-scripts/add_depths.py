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

def add_depths(vcf_path, depths_path):
    """Add depths to a merged multisample vcf

    Caveat:
        The vcf must not have a # at the beggining of the CHROM ... line

    Args:
        vcf_path (string/path): path to the vcf file
        depths_path (string/path): path to the corresponding depths file
    """
    vcf = pd.read_table(vcf_path, sep="\t",comment="#")
    nsamples = vcf.shape[1]-9
    depths= pd.read_table(depths_path, sep="\t", names=["CHROM","POS"]+[str(i) for i in range(nsamples)])
    vcf=pd.merge(vcf, depths, on=["CHROM", "POS"], how="left")
    vcf["FORMAT"]+=":QD"
    for i in range(nsamples):
        vcf.iloc[:,9+i]+=":"+vcf.iloc[:,9+nsamples+i].astype(str)

    header = []
    with open(vcf_path, "r") as file:
        for line in file:
            if line[0]=="#":
                header.append(line)         
            else:
                break
        
    header.append("#")
    vcf=vcf.iloc[:,:-nsamples]

    with open(vcf_path, "w") as file:
        file.writelines(header)
        vcf.to_csv(file, sep="\t", index = None)

if __name__=="__main__":
    if len(sys.argv)==3:
        add_depths(sys.argv[1], sys.argv[2])
    else:
        print("USAGE: [merged_vcf] [depths_file]", file=sys.stderr)