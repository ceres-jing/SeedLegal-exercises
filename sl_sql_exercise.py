"""
    INFO: This exercise is not timed, and you may use any available resources.
        https://www.onlinegdb.com/online_python_interpreter is a Python interpreter if you need it.

    TODO: Please resolve the comments in the code below.
    TODO: Please refactor the code to make it more maintainable.
        - Add any new comments that you think would help.
"""


import argparse
from concurrent.futures.thread import _worker
import os
import re
from dataclasses import dataclass, field


@dataclass()
class Baz:
    """
        Aim
        ----------
        count the number of matched files, lines, words

        Parameters
        ----------
        working_directory : re.Pattern
            the path of the folder 
        pattern : str
            the pattern of the searching files
        file_count: int 
            default to be 0
        line_count: int 
            default to be 0
        word_count:int = 0
            default to be 0
        
        Returns
        -------
        tuple
            (file_count,line_count,word_count)
        '''
    """

    pattern: str = field(compare=False)
    working_directory: re.Pattern = field(compare=False)
    file_count:int = 0
    line_count:int = 0
    word_count:int = 0

    def value_count(self):

        """
        This function will return the number of the matched files, 
        and also the number of lines and words in the matched file of a given directory.
        """
        pattern = self.pattern
        working_directory = self.working_directory
        file_count = self.file_count
        line_count = self.line_count 
        word_count = self.word_count


        for dirpath, dirname, file in os.walk(working_directory):
            for aimed_file in file:
                if re.compile(pattern).findall(aimed_file):
                    file_count += 1
                    with open(os.path.join(dirpath, aimed_file), 'r') as g:
                        i = g.readlines()
                        line_count += len(i)
                        for j in i:
                            word_count += len(j)

        return file_count,line_count,word_count

# --------------------------------------------------------------------------- #

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-pattern', default=r'^sl_.*\.py$')
    parser.add_argument('-working_directory', default=os.getcwd())
    x = parser.parse_args()
    
    help(Baz)
    print(Baz(x.pattern, x.working_directory).value_count())


'''
Reflection of this code:
The usages of @dataclass() and argparse.ArgumentParser() are not familiar to me in the first place,
I have searched some documents and tutorials of them online. 
Then I realized @dataclass() is the module to make it easier to create data classes. 
it contains two functions:
code generators: generate boilerplate code; implement them automatically.
Data containers: structures that hold data, and attribute access.

And argparse defines what arguments it requires, and it will figure out how to parse those. 
At the same time, it will also automatically generates help and usage messages, which makes it very user-friendly.

After figuring out these puzzles, I then read and run the core function to see how it works and figure out the meaning of 
each argument, then go back to the class and revise the argument's name to make it more readable.
I also changed parts of the original code to make it concise. For example, since the argument has been initialized in the beginning 
of the class, there is no need to set the default value again within the function. Besides, I add return value to the function.

Last, I run the file again to make sure it goes well. And also add comment to the function and the class.
'''





