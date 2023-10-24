# ICSE 2024 Demonstration - Boidae

This repository serves as the landing page for the ICSE 2024 demo of Boidae.

## Sub-modules

This repository also contains several sub-modules, to make it easier to find
each component.  These include:

- ansible
  - This is the set of Ansible scripts for installing Boa onto a cluster.
- compiler
  - This is the Boa language runtime and compiler infrastructure.
- docker
  - This is a Docker config for running Boa locally.
- drupal
  - This is the Drupal module that servers as Boa's frontend.

Be sure to run `git submodule update --init --recursive` after checking out
this repository so that the sub-modules are also checked out.

## Installing Boidae

Boidae comes in two varieties, allowing you to run it either locally or scale
it up to a cluster for processing larger datasets.

### Running Locally

To run locally, utilize the Docker scripts.  See the [readme](docker/README.md)
in the `docker` module for more details.

### Running on a Cluster

To run on a cluster, utilize the Ansible scripts.  See the
[readme](ansible/README.md) in the `ansible` module for more details.

## Demo

Note that for demonstration purposes, we rely on the local/Docker installation.

The demonstration provides several examples to demonstrate how one could build
their own, custom dataset to analyze in Boa and then how one could extend the
language/runtime to add custom data analysis capabilities.

Note that neither of these features being demonstrated are possible in Boa
itself, demonstrating the usefulness of Boidae for researchers.

----

### Making a Custom Dataset

First, we demonstrate how a researcher can build their own, custom dataset for
use in Boa.  While Boa provides several pre-existing datasets that span several
programming languages (Java, Python, and Kotlin), researchers may wish to
analyze other data.  For example, they may wish to build a dataset with a
specific set of projects to perform a more direct one-to-one comparison with a
prior work.  Or they may wish to build a dataset from proprietary data to
compare against results generated from the open-source datasets.

While there are several ways to build datasets with Boidae (see the `boa.sh -g` command in the `/compiler/` directory), we will utilize one specific helper script.  This script expects arguments that are the names of GitHub repositories.  So for example, to build a new dataset from Guava, you would run:

> dataset-build.sh google/guava

This will clone the repository and build a new dataset in `/compiler/dataset-new/ds/`.  You then install the dataset into Hadoop's HDFS with the `dataset-install.sh` command.  This command expects the path of the dataset you build and then a name to store it as in HDFS.  So for example, we run:

> dataset-install.sh dataset-new/ds test

This installs it with the name 'test'.

#### Adding and Querying the Custom Dataset to Drupal

Now we need to log into the web interface and click on "Dataset List" on the left.  This will let us "Add a dataset".  Here, you need to give a name for the dataset - this is what users would see in the dropdown menu.  You also need to give the name of the compiler to use (e.g., "live") and the dataset name on HDFS (e.g., "test").

Now you can query the dataset just as you would any other.  Once added, you should be able to see it in the dropdown list of datasets.

----

### Extending the Query Language

Boa provides a set of built-in, domain-specific functions to help researchers
mine source code.  For example, someone looking for files that contain string
literals in Java might write:

```
before e: Expression ->
    if (e.kind == ExpressionKind.LITERAL && def(e.literal) && match(`^"`, e.literal))
        ...
```

This works, but the code is easier to write (and understand) with the help
of a function:

```
before e: Expression ->
    if (isstringlit(e))
        ...
```

If someone wanted to find code that calls Java's `toString()` method, at the
moment they would have to manually attempt to match that.  Instead, with
Boidae, they can write a custom function in Java that does the match allowing
them to then call it from Boa queries.

```
@FunctionSpec(name = "callsToString", returnType = "bool", formalParameters = { "Expression" })
public static boolean demoFunction(final Expression e) {
   return e.getKind() == ExpressionKind.METHODCALL && e.getMethod().equals("toString");
}
```

Adding this function requires running the `compiler-install.sh` command.  It takes a single argument, that will be the name of this version of the compiler.  The command will rebuild the compiler and install it in the system with the given name.  It is then available to be assigned to a dataset.
