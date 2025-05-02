'''
functions for launching specific .ck files:

each function's name matches a .ck file in the 'chucK_play_dir' (defined in chucKShell.py)

each function's signature provides a list of keyword args and default values which get provided
  to the shell command to launch the corresponding .ck file in the running ChucK subprocess, in 
  the order in which they appear in the signature, overridden by the value of any args explicity 
  provided in the function's call.

If a function's signature isn't empty, the first arg must be '*' to specify that the following
  args are kwargs which can be provided in any order in the function call.
'''

def fauckPhiEnv(*, oct=0, pulse=8, scale=1): ()
def slicing(): () 
