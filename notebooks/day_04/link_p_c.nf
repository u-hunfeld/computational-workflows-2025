#!/usr/bin/env nextflow

process SPLITLETTERS {
    
    input:
    tuple val(block_size), val(input_str), val(out_name)

    output:
    path "*.txt"

    script:
    // split string into chunks and write each to a file
    """
    #!/usr/bin/env python
    s="${input_str}"
    n=${block_size}
    prefix="${out_name}"
    count = 0
    for i in range(0, len(s), n):
        chunk_file = f"{prefix}_{i//n+1}_{count}.txt"
        with open(chunk_file, "w") as f:
            f.write(s[i:i+n])
        count = count+1

    """ 
} 

process CONVERTTOUPPER {
    publishDir "results/chunk_files", mode: 'copy'

    input:
    path chunk_file

    output:
    path "*.txt"

    script:
    """
    awk '{ print toupper(\$0) }' $chunk_file > upper_${chunk_file}
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet
        Channel
            .fromPath('samplesheet_2.csv')
            .splitCsv(header: true)
            .map { row -> 
                    tuple(row.block_size.toInteger(), 
                        row.input_str, 
                        row.out_name)}
            .view()
    // split the input string into chunks
        | SPLITLETTERS
    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory
        | CONVERTTOUPPER





}