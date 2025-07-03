README.txt

Into this directory, place any Haskell .hs files that we wish to use from Python via Hyphen
Compile them like this:

compile_shared <HaskellFile.hs> # bash function defined in ~/.bashrc

Add these lines to the top of any Python script to load the dylibs compiled from these .hs files:

import sys
sys.path.insert(0, "/home/subhan/ext/hyphen") # so the hyphen module can be found by the import statement on the next line
import hyphen
sys.path.insert(0, "../../hyphen")  # puts this folder on the path (if the host python file resides within "dubtechne/src/_py/<some-subdirectory>")
hyphen.find_and_load_haskell_source(check_full_path=True)  # loads all .hs-compiled dylibs found on the system path

For easy copying, here they are again without comments:

import sys
sys.path.insert(0, "/home/subhan/ext/hyphen")
import hyphen
sys.path.insert(0, "../../hyphen")
hyphen.find_and_load_haskell_source(check_full_path=True)  

