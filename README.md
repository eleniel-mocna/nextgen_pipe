# NGS pipeline

## Architecture

This pipeline is segmented into individual bash scripts for each tool, so that
it can be used as a bash pipeline. Every script takes a config file and input
files and prints the config file and output files.

### Config file

There is a lot of configuring to be done for every script. This has been
put into one configuration file. The default config file is `config_file.sh`
and can be used as an example. It will be loaded before the specified config
file so that all settings are present.

Variables defined in the config file have the following notation:
`[tool_name]_[VARIABLE_NAME]`

### Input

Every script takes a path to a config file
and then paths/arguments for files for processing. Input can be given in these
3 ways:

1) All in stdin:

   - First line of stdin is the path to the config file
   - All following lines are arguments for the given script

2) Config as CL argument, arguments as stdin:

   - The first CL argument is the path to the config file
   - All arguments are given via stdin separated by new lines

3) All as CL arguments:

   - The first argument is the path to the config file
   - All following arguments are program arguments

#### Example input

1) `(/prepare.sh | /do_something.sh)<stdin`

    ```(input)
    # stdin:
    /config_file.sh
    Name1
    file1R1.fq
    file1R2.fq
    Name2
    file2R2.fq
    file2R2.fq
    ```

2) `(/prepare.sh /config_file.sh | /do_something.sh)<stdin`

    ```(input)
    # stdin:
    Name1
    file1R1.fq
    file1R2.fq
    Name2
    file2R2.fq
    file2R2.fq
    ```

3) `(/prepare.sh /config_file.sh Name1 file1R1.fq file1R2.fq file2R1.fq file2R2.fq| /do_something.sh)`

### Creating a new script

## TODO

- Add an absolute path to input_reader.sh
- `-` as a config file means the default config file is to be used
- Add default configuration file
- main docker needs: bash
- main docker needs: apk add coreutils
