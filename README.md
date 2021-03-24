# ICVI-Examples

Example usage of the Incremental Cluster Validity Indices (ICVI) implemented in the AdaptiveResonance.jl julia package.

This package is developed and maintained by [Sasha Petrenko](https://github.com/AP6YC) with sponsorship by the [Applied Computational Intelligence Laboratory (ACIL)](https://acil.mst.edu/). This project is supported by grants from the [Night Vision Electronic Sensors Directorate](https://c5isr.ccdc.army.mil/inside_c5isr_center/nvesd/), the [DARPA Lifelong Learning Machines (L2M) program](https://www.darpa.mil/program/lifelong-learning-machines), [Teledyne Technologies](http://www.teledyne.com/), and the [National Science Foundation](https://www.nsf.gov/).
The material, findings, and conclusions here do not necessarily reflect the views of these entities.

## Table of Contents

- [ICVI-Examples](#icvi-examples)
  - [Table of Contents](#table-of-contents)
  - [Outline](#outline)
  - [Structure](#structure)
  - [Usage](#usage)
    - [Data](#data)
    - [Instantiation](#instantiation)
    - [Incremental vs. Batch](#incremental-vs-batch)
    - [Updating](#updating)
    - [Criterion Values](#criterion-values)
    - [Porcelain](#porcelain)
  - [Authors](#authors)

## Outline

This Julia project contains an outline of the conceptual usage of CVIs along with many example scripts.
[Structure](##Structure) outlines the project file structure, giving context to the locations of every component of the project.
[Usage](##Usage) outlines the general syntax and workflow of the ICVIs, while [Authors](##Authors) gives credit to the author(s).

## Structure

```console
AdaptiveResonance
├── .github/workflows       // GitHub: workflows for testing and documentation.
├── data                    // Data: CI and example data location.
├── src                     // Source: scripts and common helper functions.
│   └───examples            //      Example scripts for CVI usage.
├── test                    // Test: unit, integration, and environment tests.
├── .gitignore              // Git: .gitignore for the whole project.
├── LICENSE                 // Doc: the license to the project.
├── Manifest.toml           // Julia: the explicit package versions used.
├── Project.toml            // Julia: the Pkg.jl dependencies of the project.
└── README.md               // Doc: this document.
```

## Usage

The usage of these CVIs requires an understanding of:
- [Data](###Data) assumptions of the CVIs.
- [How to instantiate](###Instantiation) the CVIs.
- [Incremental vs. batch](###Incremental-vs.-Batch) evaluation.
- [Updating](###Updating) internal CVI parameters.
- [Computing and extracting](###Criterion-Values) the criterion values.
- [Porcelain functions](###Porcelain) that are available to simplify operation.

### Data

Because Julia is programmed in a column-major fashion, all CVIs make the assumption that the first dimension (columns) contains features, while the second dimension (rows) contains samples.
This is more important for batch operation, as incremental operation accepts 1-D sample of features at each time step by definition.

For example,

```julia
# Load data from somewhere
data = load_data()
# The data shape is dimsion x samples
dim, n_samples = size(data)
```

### Instantiation

The names of each CVI are capital abbreviations of their literature names, often based upon the surname of the principal authors of the papers that introduce the metrics.
All CVIs are implemented with the default constructor, such as

```julia
cvi = DB()
```

### Incremental vs. Batch

The CVIs in this project all contain *incremental* and *batch* implementations.
When evaluated in incremental mode, they are often called ICVIs (incremental cluster validity indices).
In documentation, CVI refers to both modalities (as in the literature), but in code, CVI means batch and ICVI means incremental.

The funtions that differ between the two modes are how they are updated

```julia
# Incremental
param_inc!(...)
# Batch
param_batch!(...)
```

and their respective porcelain functions

```julia
# Incremental
get_icvi!(...)
# Batch
get_cvi!(...)
```

They both compute their most recent criterion values with

```julia
evaluate!(...)
```

NOTE: Any CVI can switch to be updated incrementally or in batch, as the CVI data structs are update mode agnostic.

### Updating

The CVIs in this project all contain internal *parameters* that must be updated.
Each update function modifies the CVI, so they use the Julia nomenclature convention of appending an exclamation point to indicate as much.

In both incremental and batch modes, the parameter update requires:

- The CVI being updates
- The sample (or array of samples)
- The label(s) that was/were prescribed by the clustering algorithm to the sample(s)

More concretely, they are

```julia
# Incremental updating
param_inc!(cvi::C, sample::Array{T, 1}, label::I) where {C<:AbstractCVI, T<:Real, I<:Int}
# Batch updating
param_batch!(cvi::C, data::Array{T, 2}, labels::Array{I, 1}) where {C<:AbstractCVI, T<:Real, I<:Int}
```

Every CVI is a subtype of the abstract type `AbstractCVI`.
For example, we may instantiate and load our data

```julia
cvi = DB()
data = load_data()
labels = get_cluster_labels(data)
dim, n_samples = size(data)
```

then update the parameters incrementally with

```julia
for ix = 1:n_samples
    sample = data[:, ix]
    label = labels[ix]
    param_inc!(cvi, sample, labels)
end
```

or in batch with

```julia
param_batch!(cvi, data, labels)
```

Furthermore, any CVI can alternate between being updated in incremental or batch modes, such as

```julia
# Create a new CVI
cvi_mixed = DB()

# Update on half of the data incrementally
i_split = n_samples/2
for ix = 1:i_split
    param_inc!(cvi, data[:, ix], labels[ix])
end

# Update on the other half all at once
param_batch!(cvi, data[:, (i_split+1):end])
```

### Criterion Values

The CVI parameters are separate from the criterion values that they produce.
This is partly because in batch mode computing the criterion value is only relevant at the last step, which eliminates unnecessarily computing it at every step.
This is also provide granularity to the user that may only which to extract the criterion value occasionally during incremental mode.

Because the criterion values only depend on the internal CVI parameters, they are computed (and internally stored) with

```julia
evaluate!(cvi::C) where {C<:AbstractCVI}
```

To extract them, you must then simply grab the criterion value from the CVI struct with

```julia
criterion_value = cvi.criterion_value
```

For example, after loading the data

```julia
cvi = DB()
data = load_data()
labels = get_cluster_labels(data)
dim, n_samples = size(data)
```

we may extract and return the criterion value at every step with

```julia
criterion_values = zeros(n_samples)
for ix = 1:n_samples
    param_inc!(cvi, data[:, ix], labels[ix])
    evaluate!(cvi)
    criterion_values[ix] = cvi.criterion_value
end
```

or we may get it at the end in batch mode with

```julia
param_batch!(cvi, data, labels)
evaluate!(cvi)
criterion_value = cvi.criterion_value
```

### Porcelain

Taken from the `git` convention of calling low-level operations *plumbing* and high-level user-land functions *porcelain*, the package comes with a small set of *porcelain* function that do common operations all at once for the user.

For example, you may compute, evalute, and return the criterion value all at once with the functions

```julia
# Incremental
get_icvi!(...)
# Batch
get_cvi!(...)
```

Exactly as in the usage for updating the parameters, the functions take the cvi, sample(s), and clustered label(s) as input:

```julia
# Incremental
get_icvi!(cvi::C, x::Array{N, 1}, y::M) where {C<:AbstractCVI, N<:Real, M<:Int}
# Batch
get_cvi!(cvi::C, x::Array{N, 2}, y::Array{M, 1}) where {C<:AbstractCVI, N<:Real, M<:Int}
```

For example, after loading the data you may get the criterion value at each step with

```julia
criterion_values = zeros(n_samples)
for ix = 1:n_samples
    criterion_values = get_icvi!(cvi, data[:, ix], labels[ix])
end
```

or you may get the final criterion value in batch mode with

```julia
criterion_value = get_cvi!(cvi, data, labels)
```

## Authors

- Sasha Petrenko <sap625@mst.edu>
