import git
import os
import pandas as pd
from pathlib import Path
from snakemake.utils import validate
from snakemake.utils import min_version


min_version("5.32.0")


### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_table(config["samples"]).set_index("sample", drop=False)

validate(samples, schema="../schemas/samples.schema.yaml")

### Import subworkflows


def get_subworkflow(name, url, tag, target):
    Path(target).mkdir(exist_ok=True)
    repo_dir = "{base}/{repo}".format(base=target, repo=name)
    if not os.path.exists(repo_dir):
        git.Git(target).clone(url, branch=tag)
        print("Successfully retrieved {name} version {tag}".format(name=name, tag=tag))
    else:
        git.Git(repo_dir).checkout(tag)
        print(
            "Successfully checked out {name} version {tag}".format(name=name, tag=tag)
        )
    return


def get_all_subworkflows(config, target):
    for workflow in config["workflows"]:
        get_subworkflow(
            workflow,
            config["workflows"][workflow]["url"],
            config["workflows"][workflow]["tag"],
            target,
        )


work_dir = os.getcwd()

swf_dir = "{workdir}/subworkflows".format(workdir=work_dir)

get_all_subworkflows(config, swf_dir)


subworkflow wgs_std_viper:
    workdir: work_dir
    snakefile: "{swfdir}/wgs_std_viper/Snakefile".format(swfdir=swf_dir)
    configfile: "{workdir}/config.yaml".format(workdir=work_dir)


### Functions


def get_loci(loci):
    loci_tab = pd.read_table(loci, header=None, dtype=str)
    return loci_tab[0].tolist()
