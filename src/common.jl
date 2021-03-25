using DelimitedFiles

"""
    get_cvi_data(data_file::String)

Get the cvi data specified by the data_file path.
"""
function get_cvi_data(data_file::String)
    # Parse the data
    data = readdlm(data_file, ',')
    data = permutedims(data)
    train_x = data[1:2, :]
    train_y = convert(Array{Int64}, data[3, :])

    return train_x, train_y
end # get_cvi_data(data_file::String)

"""
    sort_cvi_data(data::Array{N, 2}, labels::Array{M, 1}) where {N<:Real, M<:Int}

Sorts the CVI data by the label index, assuring that clusters are provided incrementally.
"""
function sort_cvi_data(data::Array{N, 2}, labels::Array{M, 1}) where {N<:Real, M<:Int}
    index = sortperm(labels)
    data = data[:, index]
    labels = labels[index]

    return data, labels
end # sort_cvi_data(data::Array{N, 2}, labels::Array{M, 1}) where {N<:Real, M<:Int}
