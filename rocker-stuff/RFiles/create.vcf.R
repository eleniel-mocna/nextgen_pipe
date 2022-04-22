args=(commandArgs(TRUE))
require(VariantAnnotation)
rc_in=args[1]
vcf_out=args[2]

read.rc<-function(file){
    serv<-scan(file,what="character",sep="\n",skip=1)
    serv<-strsplit(serv,split="\t")

    parse.line<-function(x){
        ii<-grep(":",x[-c(1:5)])+4
        if (length(ii)==1) ii<-length(x) else ii<-ii[2]
        ref<-strsplit(x[6],split=":")[[1]]
        ref<-ref[c(2,6,7)]
        x<-c(x[1],x[2],x[3],x[4],x[5],ref,x[-c(1:5,6,7:ii)])

        stV<-5+length(ref)
        if (stV>=length(x)) return(NULL)
        x<-lapply((stV+1):length(x),FUN=function(i) {
            xx<-c(x[1:stV],strsplit(x[i],split=":")[[1]])
            return(xx)

        })

    }
    serv<-lapply(serv,FUN=parse.line)


    serv

}

make.vcf<-function(file,sample="S1"){
    serv<-read.rc(file)

    serv<-do.call("rbind",do.call("c",serv))

    colnames(serv)<-c("Chr","Pos","ref","DP","QDP","refDepth","refPlus","refMinus","alt","DPV","strands","avg_qual","map_qual","plus_reads","minus_reads")

    serv<-as.data.frame(serv,stringsAsFactors=FALSE)


    vcf.format<-function(refvar){
        ref<-refvar[1]

        var<-refvar[2]

        if(length(grep("INS",var))>0){
            return(c(ref,paste(ref,sub("INS-[0-9]+-","",var),sep="")))
        } else if (length(grep("DEL",var))>0){
            return(c(paste(ref,sub("DEL-[0-9]+-","",var),sep=""),ref))
        } else return(c(ref,var))

    }

    rv<-t(apply(cbind(serv$ref,serv$alt),MARGIN=1,FUN=vcf.format))

    vcf<-VRanges(seqnames=serv$Chr,
                    ranges=IRanges(as.numeric(serv$Pos),
                                    as.numeric(serv$Pos)),
                                    ref=rv[,1],
                                    alt=rv[,2],
                                    totalDepth=as.numeric(serv$DP),
                                    qualDepth=as.numeric(serv$QDP),
                                    refDepth=as.numeric(serv$refDepth),
                                    altDepth=as.numeric(serv$DPV),
                                    plusVReads=as.numeric(serv$plus_reads),
                                    minusVReads=as.numeric(serv$minus_reads),
                                    plusRReads=as.numeric(serv$refPlus),
                                    minusRReads=as.numeric(serv$refMinus),
                                    FREQ=as.numeric(serv$DPV)/as.numeric(serv$DP),
                                    sampleNames=sample)
}

vcf<-as(make.vcf(rc_in),"VCF")
writeVcf(vcf,filename=vcf_out)  

# rc_in="$file.var.readcounts.txt"
# vcf_out="$file.rc.vcf"

# "R CMD BATCH  --no-save --no-restore '--args rc_in=\"$file.var.readcounts.txt\"\
#   vcf_out=\"$file.rc.vcf\" pathRscript=\"$NEXTGEN/finish_rc_dev.R\"' $NEXTGEN/create.vcf.R diag.out"