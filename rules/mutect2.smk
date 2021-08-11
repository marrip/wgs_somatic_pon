rule mutect2_normal:
    input:
        bam=wgs_std_viper(
            "analysis_output/{sample}/gather_bam_files/{sample}.bam",
        ),
        ref=config["reference"]["fasta"],
    output:
        "analysis_output/{sample}/mutect2/{sample}_{locus}.vcf"
    log:
        "analysis_output/{sample}/mutect2/{sample}_{locus}.log"
    container:
        config["tools"]["gatk"]
    message:
        "{rule}: Call variants for {wildcards.sample} at {wildcards.locus}"
    shell:
        "gatk Mutect2 "
        "-I {input.bam} "
        "-R {input.ref} "
        "-L {wildcards.locus} "
        "--max-mnp-distance 0 "
        "-O {output} &> {log}"


rule merge_vcf:
    input:
        dct=config["reference"]["dct"],
        files=get_all_vcf,
    output:
        "analysis_output/{sample}/mutect2/{sample}.vcf",
    params:
        get_fmt_vcf,
    log:
        "analysis_output/{sample}/mutect2/{sample}.log",
    container:
        config["tools"]["gatk"]
    message:
        "{rule}: Concatenate {wildcards.sample} vcf files"
    shell:
        "gatk MergeVcfs "
        "-I {params} "
        "-D {input.dct} "
        "-O {output} &> {log}"

rule mutect2_genomics_db_import:
    input:
        vcf=expand("analysis_output/{sample}/mutect2/{sample}.vcf", sample=samples.index),
        ref=config["reference"]["fasta"],
        intervals=config["reference"]["intervals"]
    output:
        directory("analysis_output/pon/mutect2_somatic_pon"),
    params:
        get_fmt_sample_vcf,
    log:
        "analysis_output/pon/mutect2_genomics_db_import.log",
    container:
        config["tools"]["gatk"]
    message:
        "{rule}: Generate panel of normals database for mutect2"
    shell:
        "gatk GenomicsDBImport "
        "-R {input.ref} "
        "-L {input.intervals} "
        "-V {params} "
        "--genomicsdb-workspace-path {output} &> {log}"


rule mutect2_somatic_pon:
    input:
        db="analysis_output/pon/mutect2_somatic_pon",
        ref=config["reference"]["fasta"],
        gnomad=config["mutect2"]["gnomad"],
    output:
        "analysis_output/pon/mutect2_somatic_pon.vcf",
    log:
        "analysis_output/pon/mutect2_somatic_pon.log",
    container:
        config["tools"]["gatk"]
    message:
        "{rule}: Generate panel of normals vcf for mutect2"
    shell:
        "gatk CreateSomaticPanelOfNormals "
        "-R {input.ref} "
        "--germline-resource {input.gnomad} "
        "-V gendb://{input.db} "
        "-O {output} &> {log}"
