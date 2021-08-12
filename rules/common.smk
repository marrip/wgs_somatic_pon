import git
import os
import pandas as pd
from pathlib import Path
from snakemake.utils import validate
from snakemake.utils import min_version


min_version("6.5.3")


### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_table(config["samples"], dtype=str).set_index("sample", drop=False)

validate(samples, schema="../schemas/samples.schema.yaml")


### Functions


def get_snakefile(workflow, tags):
    return "https://github.com/marrip/%s/raw/%s/Snakefile" % (workflow, tags[workflow])


def get_loci(loci):
    loci_tab = pd.read_table(loci, header=None, dtype=str)
    return loci_tab[0].tolist()


### Import subworkflows


module wgs_std_viper:
    snakefile: get_snakefile("wgs_std_viper", config["workflows"])
    config: config

use rule * from wgs_std_viper as wgs_std_*
