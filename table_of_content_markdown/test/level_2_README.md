
<a name="Creating Markdown Table of Contents."></a>

# Creating Markdown Table of Contents.


---

###Table of Contents

1. <a href="#Code Usage.">Code Usage.</a>
	 * <a href="#Two Level Table of Content">Two Level Table of Content</a>
	 * <a href="#Three Level Table of Content">Three Level Table of Content</a>
2. <a href="#More Information">More Information</a>

---



<a name="Lets begin"></a>

# Lets begin 


<a name="Code Usage."></a>

## Code Usage.

Just call the functions as below.


<a name="Two Level Table of Content"></a>

###Two Level Table of Content 

Processing `##` and `###` excluding `#`
    
    table_of_contents_2_levels("README.md", "test/level_2_README.md")


<a name="Three Level Table of Content"></a>

###Three Level Table of Content 

Processing `#`, `##` and `###`

    table_of_contents_3_levels("README.md", "test/level_3_README.md")


<a name="More Information"></a>

## More Information

    table_of_contents_2_levels("README.md", "test/level_2_README.md")
    table_of_contents_3_levels("README.md", "test/level_3_README.md")

    table_of_contents_2_levels("TEST_README.md", "test/level_2_TEST_README.md")
    table_of_contents_3_levels("TEST_README.md", "test/level_3_TEST_README.md")
    

