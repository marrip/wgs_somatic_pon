rule cnvkit_access:
    input:
        config["reference"]["fasta"],
    output:
        "analysis_output/pon/access-10kb.mm2.bed",
    container:
        config["tools"]["cnvkit"]
    log:
        "analysis_output/pon/cnvkit_access.log",
    message:
        "{rule}: Generate access bed file for cnvkit"
    shell:
        """
        cnvkit.py access \
        {input} \
        -s 10000 \
        -o {output} &> {log}
        """


rule cnvkit_somatic_pon:
    input:
        bam=expand(
            "analysis_output/{sample}/gather_bam_files/{sample}_N.bam",
            sample=get_normals(),
        ),
        ref=config["reference"]["fasta"],
        access="analysis_output/pon/access-10kb.mm2.bed",
    output:
        "analysis_output/pon/cnvkit_somatic_pon.cnn",
    log:
        "analysis_output/pon/cnvkit_somatic_pon.log",
    container:
        config["tools"]["cnvkit"]
    message:
        "{rule}: Generate panel of normals for cnvkit"
    threads: 40
    shell:
        """
        cnvkit.py batch \
        -n {input.bam} \
        -m wgs \
        -f {input.ref} \
        -g {input.access} \
        -p {threads} \
        -d analysis_output/pon/ \
        --output-reference {output} &> {log}
        """
