#
# AHMED
#

import re
import os

def create_toc_2_levels(input_file):
    '''
    :param input_file:
        Takes a markdown file as input.
    :return: Table of Content
    '''
    readr = open(input_file, "r")

    count = 1
    toc_string = "\n\n---\n\n###Table of Contents\n"
    for item in readr.readlines():
        if item[0] == '#' and item[1] != '#':
            continue
        elif item[0] == '#' and item[1] == '#' and item[2] != '#':
            display_str = item.strip('#').strip()
            link_str = create_dash_link(item.strip('#').strip())
            toc_string += "\n" + "* <a href=\"#" + link_str + "\">" + display_str + "</a>"
        elif item[0] == '#' and item[1] == '#' and item[2] == '#':
            display_str = item.strip('#').strip()
            link_str = create_dash_link(item.strip('#').strip())
            toc_string += "\n" + "\t* <a href=\"#" + link_str + "\">" + display_str + "</a>"
        else:
            continue

    toc_string += "\n\n---\n\n"

    readr.close()
    return  toc_string

def create_toc_3_levels(input_file):
    '''
    :param input_file:
        Takes a markdown file as input.
    :return: Table of Content
    '''

    readr = open(input_file, "r")

    count = 1
    toc_string = "\n\n---\n\n###Table of Contents\n"
    for item in readr.readlines():
        if item[0] == '#' and item[1] != '#':
            display_str = item.strip('#').strip()
            link_str = create_dash_link(item.strip('#').strip())
            toc_string += "\n" + str(count)+ ". " + "<a href=\"#" + link_str + "\">" + display_str + "</a>"
            count += 1
        elif item[0] == '#' and item[1] == '#' and item[2] != '#':
            display_str = item.strip('#').strip()
            link_str = create_dash_link(item.strip('#').strip())
            toc_string += "\n" + "\t * <a href=\"#" + link_str + "\">" + display_str + "</a>"
        elif item[0] == '#' and item[1] == '#' and item[2] == '#':
            display_str = item.strip('#').strip()
            link_str = create_dash_link(item.strip('#').strip())
            toc_string += "\n" + "\t\t * <a href=\"#" + link_str + "\">" + display_str + "</a>"
        else:
            continue

    toc_string += "\n\n---\n\n"

    readr.close()
    return  toc_string


def create_dash_link(input_string):
    return re.sub('[^A-Za-z0-9]+', '', input_string)



def create_links(input_file, output_file, toc_string):
    '''

    :param input_file:
    :param output_file:
    :param toc_string: we get this from the above methods.
    :return: Creates a New file as in `output_file`
    '''

    # Read from input process and create a new output file.
    input_file_reader = open(input_file, 'r')
    output_file_reader = open(output_file, 'w')

    # Setting line counter we will create a TOC on line 2.
    line_counter = 1

    # Process
    for line in input_file_reader:

        # Create TOC on line 2.
        if line_counter == 2:
            output_file_reader.write(toc_string)

        # Creating <a name> for all the `#` tags.
        if line[0] == '#' and line[1] != '#':
            ahref_string = create_dash_link(line.strip("#").strip())
            output_file_reader.write(line.replace("#", "\n<a name=\""+ahref_string+"\"></a>\n\n#"))
            #output_file_reader.write(line)
            line_counter += 1
        elif line[0] == '#' and line[1] == '#' and line[2] != '#':
            ahref_string = create_dash_link(line.strip("#").strip())
            print create_dash_link(ahref_string)
            output_file_reader.write(line.replace("##", "\n<a name=\""+ahref_string+"\"></a>\n\n##"))
            line_counter += 1
        elif line[0] == '#' and line[1] == '#' and line[2] == '#':
            ahref_string = create_dash_link(line.strip("#").strip())
            print create_dash_link(ahref_string)
            output_file_reader.write(line.replace("###", "\n<a name=\""+ahref_string+"\"></a>\n\n###"))
            line_counter += 1

        # We process as it is for other lines which dont have any `#` in the beginning
        else:
            output_file_reader.write(line)
            line_counter+=1

    # Closing files
    input_file_reader.close()
    output_file_reader.close()

# Combiner function
def table_of_contents_2_levels(input, output):
    create_links(input, output, create_toc_2_levels(input))

# Combiner
def table_of_contents_3_levels(input, output):
    create_links(input, output, create_toc_3_levels(input))


# --------------------------------------------------------
# Process
# --------------------------------------------------------
if __name__ == '__main__':

    # table_of_contents_2_levels("README.md", "test/level_2_README.md")
    # table_of_contents_3_levels("README.md", "test/level_3_README.md")
    #
    # table_of_contents_2_levels("TEST_README.md", "test/level_2_TEST_README.md")
    # table_of_contents_3_levels("TEST_README.md", "test/level_3_TEST_README.md")
    #
    # table_of_contents_2_levels("C:\Users\Zubair\Box Sync\GitHub\\big_config\hadoop\README.md", "C:\Users\Zubair\Box Sync\GitHub\\big_config\hadoop\XREADME.md")

    #table_of_contents_2_levels("orig/kvm_readme.md", "upd_toc/update_kvm_readmd.md")

    level_2_directory = "orig/level_2/"
    level_3_directory = "orig/level_3/"

    level_2_directory_update = "updated_toc/level_2/"
    level_3_directory_update = "updated_toc/level_3/"

    read_l2_files_list = os.listdir(level_2_directory)
    read_l3_files_list = os.listdir(level_3_directory)

    for file_l2 in read_l2_files_list:
        table_of_contents_2_levels(level_2_directory + file_l2, level_2_directory_update + file_l2)

    for file_l3 in read_l3_files_list:
        table_of_contents_3_levels(level_3_directory + file_l3, level_3_directory_update + file_l3)
