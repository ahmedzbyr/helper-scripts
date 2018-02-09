# Creating Markdown Table of Contents.

# Lets begin 

## Code Usage.

Just call the functions as below.

###Two Level Table of Content 

Processing `##` and `###` excluding `#`
    
    table_of_contents_2_levels("README.md", "test/level_2_README.md")

###Three Level Table of Content 

Processing `#`, `##` and `###`

    table_of_contents_3_levels("README.md", "test/level_3_README.md")

## More Information

    table_of_contents_2_levels("README.md", "test/level_2_README.md")
    table_of_contents_3_levels("README.md", "test/level_3_README.md")

    table_of_contents_2_levels("TEST_README.md", "test/level_2_TEST_README.md")
    table_of_contents_3_levels("TEST_README.md", "test/level_3_TEST_README.md")
    

