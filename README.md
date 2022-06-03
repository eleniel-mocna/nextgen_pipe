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

### Input in R

When the main container is started, there are prepared functions for all scripts
saved in the scripts folder. They accept the following formats of input:

- String: input arguments are in a string (e.g. `do_something("config 1st_file 2nd_file")`)
- Vector: Input arguments are in a vector (e.g. `do_something(c("config", "1st_file", "2nd_file"))`)

All basic methods can be used as described above. There are also a few control flow functions:
These accept only vector-like inputs.

- `change_config_file(input, new_config)`: Changes the used config file to the new_config.
- `merge_output_lists(config_file, ...)`: Intertwines all vectors given in `...` while using the `config_file`
   as the config file. For example:

   ```(R)
   > merge_output_lists("config", c("config0", 1,2,3), c("config1", "A", "B", "C"))
   [1] "config" "1"      "A"      "2"      "B"      "3"      "C"
   ```

For an example, see scripts/test_pipeline.R

### Input via bash

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

The easiest way to create a new script is by following instructions in scripts/template.sh.
Edit the script according to the `#TODO` tags.

## TODO

- add thread meter reseter
