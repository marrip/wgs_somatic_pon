import git
import os
import pandas as pd
from pathlib import Path
from snakemake.exceptions import WorkflowError
from snakemake.utils import validate
from snakemake.utils import min_version


min_version("6.0.0")


### Set and validate config file


configfile: "config.yaml"


validate(config, schema="../schemas/config.schema.yaml")


### Read and validate samples file


samples = pd.read_table(config["samples"], dtype=str).set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")


### Read and validate units file


units = pd.read_table(config["units"], dtype=str).set_index("sample", drop=False)
validate(units, schema="../schemas/units.schema.yaml")


### Functions


def get_loci(loci):
    loci_tab = pd.read_table(loci, header=None, dtype=str)
    return loci_tab[0].tolist()


def get_normals():
    normals = units.loc[units["unit"] == "N"].index.tolist()
    if len(normals) > 0:
        return normals
    else:
        raise WorkflowError("No normal samples found to generate panel of normals.")
