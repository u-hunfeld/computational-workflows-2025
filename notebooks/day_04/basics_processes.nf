params.step = 0
params.zip = 'zip'


process SAYHELLO {
    debug true

    script:
    """
    echo "Hello World!"
    """
}

process SAYHELLO_PYTHON {
    debug true

    script:
    //alternative way:
    //#!usr/bin/env python      
    //print("Hello World!")
    """
    python3 -c "print('Hello World!')"
    """
}


process SAYHELLO_PARAM {
    debug true

    input:
    val greeting_ch

    script:
    """
    echo "$greeting_ch"
    """
}

process SAYHELLO_FILE {
    publishDir "results", mode: 'copy'
    debug true

    input:
    val greeting_ch

    output:
    path "sayhello_file.txt"

    script:
    """
    echo "$greeting_ch" > sayhello_file.txt
    """
}


process UPPERCASE {
    publishDir "results", mode: 'copy'
    debug true

    input:
    val greeting_ch

    output:
    path "uppercase.txt"

    script:
    """
    echo "$greeting_ch" | tr '[:lower:]' '[:upper:]' > uppercase.txt
    """
}

process PRINTUPPER {
    debug true

    input:
    path out_ch

    script:
    """
    cat "$out_ch"
    """
}

process ZIPFILE {
    publishDir "results", mode: 'copy'
    debug true

    input:
    path out_ch
    val params

    output:
    path "*"

    script:
    
    if (params == "zip") {
            """
            zip zipfile.zip $out_ch
            """
        } else if (params == "gzip") {
            """
            gzip -c $out_ch > zipfile.gz
            """
        } else if (params == "bzip2") {
            """
            bzip2 -c $out_ch > zipfile.bz2
            """
        }
}

process MORE_ZIPFILES {
    publishDir "results", mode: 'copy'
    debug true

    input:
    path out_ch

    output:
    path "*"

    script:
    """
    zip more_zipfiles.zip $out_ch
    gzip -c $out_ch > more_zipfiles.gz
    bzip2 -c $out_ch > more_zipfiles.bz2
    """
}

process WRITETOFILE {
    publishDir "results", mode: 'copy'
    debug true

    input:
    val in_ch

    output:
    path "names.tsv"

    script:
    def content = in_ch.collect { "${it.name}\t${it.title}" }.join('\n')
    """
    echo -e "name\ttitle" > names.tsv
    echo -e "${content}" >> names.tsv
    """

}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        SAYHELLO()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        zipped = ZIPFILE(out_ch, params.zip)
        zipped.view()
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        zipped = MORE_ZIPFILES(out_ch)
        zipped.view()
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        ).toList()

        in_ch
            | WRITETOFILE
            // continue here

        //out_ch = WRITETOFILE(in_ch)
    }

}