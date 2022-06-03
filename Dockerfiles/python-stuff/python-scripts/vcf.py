class Variant:
    def __init__(self,
                chrom,
                pos,
                ref,
                alt,
                infoes,
                formats) -> None:
        self.chrom=chrom
        self.pos = pos
        self.ref = ref
        self.alt = alt
        self.infoes = infoes
        self.formats = formats
    def __repr__(self) -> str:
        return (f"\nVariant[chrom={self.chrom}, " +
        f"pos={self.pos}, ref={self.ref}, alt={self.alt}," +
        f"infoes={self.infoes}, formats={self.formats}")
    def same_variant(self, variant):
        return (self.chrom==variant.chrom and self.pos == variant.pos
                and self.ref== variant.ref and self.alt==variant.alt)
    def same_position(self,location):
        return self.chrom==location[0] and self.pos == location[1]
    
    @staticmethod
    def from_line(line):
        split = line.split("\t")
        return Variant(split[0],
                        split[1],
                        split[3],
                        split[4],
                        [x.split("=")[1] for x in split[7].split(";")],
                        split[9].strip().split(":"))

class Vcf:
    def __init__(self, file:str) -> None:
        self.name=file
        first=True
        self.infoes = []
        self.formats = []
        self.variants = []
        with open(file, "r") as file:
            for line in file:
                if line[0]=="#":
                    continue
                split = line.split("\t")
                if first:
                    first=False
                    self.formats=split[8].split(":")
                    whole_infoes=split[7].split(";")
                    for info in whole_infoes:
                        self.infoes.append(info.split("=")[0])
                self.variants.append(Variant(split[0],
                                        split[1],
                                        split[3],
                                        split[4],
                                        [x.split("=")[1] for x in split[7].split(";")],
                                        split[9].strip().split(":")))
    def __repr__(self) -> str:
        return f"\nVcf[name={self.name}, infoes={self.infoes}, formats={self.formats}, n. variants={len(self.variants)}]"

def get_bed_file(vcfs:list(Vcf)):
    positions = set()
    for vcf in positions:
        for variant in vcf.variants:
            positions.add((variant.chrom, variant.pos))
    position_list = list(positions)
    position_list.sort(key=get_chrom_order)
    ret = ""
    for position in positions:
        ret += f"{position[0]}\t{position[1]-1}\t{position[1]}"    
    return ret

def get_chrom_order(chr_pos):
    """Get a numbering for this location for sorting purpouses

    Args:
        chr_pos (tuple(str, int)): the given location

    Returns:
        tuple(int, int): unique numbering for this location
            - unknown chromosomes are at the back.
    """
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
    if chr_pos[0] in order:
        return (order.index(chr_pos[0]), chr_pos[1])
    else:
        return (hash(chr_pos[0])+100, chr_pos[1])

def merge_vcf(vcf_paths:list[str], bedfile_path:str, output_file_path:str, output_writer):
    vcf_files = [open(path, "r") for path in vcf_paths]
    current_variants = [[] for _ in vcf_files]
    next_variants = [Variant.from_line(file.readline()) for file in vcf_files]
    with open(bedfile_path, "r") as bedfile, open(output_file_path, "w") as output_file:
        for line in bedfile:            
            location, depths = bedfile_line(line)
            for i in range(len(vcf_files)):
                while next_variants[i].same_position(location):
                    current_variants[i].append(next_variants[i])
                    next_variants[i]=Variant.from_line(vcf_files[i].readline)
            while sum([len(variants) for variants in current_variants])>0:
                min_index = current_variants.index(min(current_variants,
                            key=lambda x: get_chrom_order(x[0].chr, x[0].pos)))
                this_variant = current_variants[min_index][0]
                output_line = []
                for i in range(len(vcf_files)):
                    if len(current_variants[i])>0 and this_variant.same_variant(current_variants[i][0]):
                        output_line

    for file in vcf_files:
        file.close()
def bedfile_line(bedfile_line:str):
    split = bedfile_line.split("\t")
    return (split[0], split[1]), split[2:]