#!/opt/homebrew/Cellar/python@3.11/3.11.5/bin/python3 -i
# %% [interactive]

import subprocess
import time
import select
import re
from collections import UserList

# For storing metadata as properties, on the list of shred_ids associated with particular ChucK file
# Each time the same ChucK file is launched, a new shred_id gets added to the list associated with that file
# and removed from the list when its associated shred is removed from the queue of actively-playing shreds
class ShredsList(UserList):
    def __init__(self, data, **attrs):
        super().__init__(data)
        self.__dict__.update(attrs)

# fauckPhiEnv_active_shreds = ShredsList([1, 2, 3], name="fauckPhiEnv")
# print(fauckPhiEnv_active_shreds)         # [1, 2, 3]
# print(fauckPhiEnv_active_shreds.name)    # "fauckPhiEnv"

def get_shred_id(log_line: str) -> int:
    """
    Extracts the integer value that follows the pattern '(VM) sporking incoming shred: '
    in the given log line.
    
    Parameters:
        log_line (str): The input string containing the log message.
    
    Returns:
        int: The extracted integer value, or None if the pattern is not found.
    """
    match = re.search(r'\(VM\) sporking incoming shred: (\d+)', log_line)
    return int(match.group(1)) if match else None


# Example usage:
# log_example = "(VM) sporking incoming shred: 42"
# value = getShredID(log_example)
# print(value)  # Output: 42

# Start the ChucK shell subprocess
process = subprocess.Popen(
    ["chuck", "--dac:Universal Audio: Volt 476P", "--shell"],  # Start ChucK shell
    stdin=subprocess.PIPE,  # Allow writing to stdin
    stdout=subprocess.PIPE,  # Capture stdout
    stderr=subprocess.PIPE,  # Capture stderr
    text=True,  # Ensure text mode for easier interaction
    bufsize=1,  # Line buffering for real-time output
)

def process_output():
    output = read_output()
    for line in output:
        print(line)
        maybe_id = check_for_launched_shred(line)
    return maybe_id if maybe_id else None

def check_for_launched_shred(str):
    maybe_id = get_shred_id(str)
    # print('check_for_launched_shred() returned', maybe_id if maybe_id else 'nothing')
    return maybe_id if maybe_id else None


# Function to send a command to the ChucK shell
def send_command(command):
    """Send a command to the ChucK shell subprocess."""
    process.stdin.write(command + '\n')
    process.stdin.flush()  # Ensure command is sent immediately
    time.sleep(0.3)  # Give some time for ChucK to process
    try:
        maybe_id = process_output()
    except:
        return None 
    else: 
        return maybe_id if maybe_id else None


def read_output():
    """Read all available lines from ChucK's output without blocking."""
    output_lines = []

    # get lines from stdout
    while True:         
        ready, _, _ = select.select([process.stdout], [], [], 0.1)  # 0.1s timeout
        if not ready:
            break  # No more data to read
        line = process.stdout.readline().strip()
        if line:
            output_lines.append(line)

    # get lines from stderr
    while True:       
        ready, _, _ = select.select([process.stderr], [], [], 0.1)  
        if not ready:
            break  # No more data to read
        line = process.stderr.readline().strip()
        if line:
            output_lines.append(line)

    return output_lines

# Example: Send a command to check the version of ChucK
#send_command("^")

# send_command("+ mesh2Dexample.ck")

# Example: Load a simple sine oscillator script in real-time
#send_command("{ 1::second => dur T; SinOsc s => dac; while (true) { T => now; } }")

# make a shortcut 
sc = send_command

# fauckPhiEnv = send_command("+ fauckPhiEnv.ck")
# send_command(f"- {fauckPhiEnv}")

# ensure {symbol} evaluates to a LIFO (last in, first out) data-structure
def ensure_symbol_evaluates_to_a_lifo(filename_as_symbol):
    # filename_as_string = f"{filename_as_symbol}"
    # if 'filename_as_symbol' is already defined, then we don't need to construct anything, and we can exit the function
    if filename_as_symbol in globals(): return
    # if 'filename_as_symbol' desn't exist yet, we construct it..
    # ..assigning to it an empty ShredsList in the global namespace 
    #print(f"LIFO created for \'{filename_as_symbol}\'")
    exec(f"{filename_as_symbol} = ShredsList([], name=\'{filename_as_symbol}\')", globals()) 
        
# functions which spork specific .ck files
def fauckPhiEnv_(suffix=None, *, oct=0, pulse=8, scale=1):
    argstr = f':{oct}:{pulse}:{scale}'
    spork('fauckPhiEnv', argstr, suffix)

def spork(filename, args=None, suffix=None):
    args = args if args else ''
    spork_file_command = f'send_command(\"+ {filename}.ck{args}\")'
    # eval() returns the shred_id number if a new shred was successfully sporked
    maybe_shred_id = eval(spork_file_command) 
    # if there's no shred_id, exit
    if not(maybe_shred_id): 
        #print('No shred_id returned')
        return 
    # since shred_id exists, we take steps below to store it in a pragmatically useful and meaningful way
    shred_id = maybe_shred_id
    #print(f"Sporking file \'{filename}.ck\' returned shred_id [{shred_id}]")
    # launching the filename successfully sporked a shred, so we construct a corresponding symbol-name from the filename with an optional suffix
    suffix = f'_{suffix}' if suffix else ''
    filename_as_symbol = f'{filename}{suffix}'
    #print("\'filename_as_symbol\' has value:", filename_as_symbol)
    # we ensure symbol evaluates to a LIFO; if it doesn't already exist, we make one
    ensure_symbol_evaluates_to_a_lifo(filename_as_symbol)
    # we push shred_id onto "the top of the stack" (i.e. we append it to the back of the LIFO array)
    exec(f'{filename_as_symbol} += [{shred_id}]', globals())
    print(eval(f'{filename_as_symbol}'), f'=> {filename_as_symbol}')

# cancel shred
def xs(arg, nthpop=0):
    # we can also remove the shred by directly providing its shred_id 
    if isinstance(arg, int): 
        send_command(f'- {arg}')
        return
    # if arg is not an int, we can assume it's a string representing the name of the .ck file that the shred is playing
    # in that case, we know that a var has been created in its name (_{filenameNoExt}_), that is a list of playing shreds
    # we retrieve that list as local variable 'list_of_shreds':
    list_of_shreds = arg
    if not(isinstance(list_of_shreds, ShredsList)):
        print(f"ERROR: {list_of_shreds.name} is not a ShredsList")
        return
    elif len(list_of_shreds) == 0:
        print(f"{list_of_shreds.name} has no more shreds to remove, it is an empty list")
        return
    else:
        if nthpop >= len(list_of_shreds):
            print(f"ERROR: {list_of_shreds.name} has only {len(list_of_shreds)} shreds, index {nthpop} is out-of-bounds")
            return
        else:  # remove the shred that is 'nthpop' places from the back of the list (i.e. the top of the stack)
            send_command(f"- {list_of_shreds[-(nthpop+1)]}")
            #removed_shred_id = list_of_shreds.pop(-(nthpop+1))
            list_of_shreds.pop(-(nthpop+1))
            #print(f"Shred {removed_shred_id} was removed from the \'{list_of_shreds.name}\' playstack")
            num_shreds_remaining = len(list_of_shreds)
            if num_shreds_remaining > 0:
                print(list_of_shreds, f"<- {list_of_shreds.name} has {len(list_of_shreds)} shreds left on its stack")
            else:
                print(f"{list_of_shreds.name} has no more active shreds on its stack")

# TODO: add logging, and if possible, a way to supply a dictionary of parameter values for that sporking, 
#   then also have it archive those settings as a .json file with a timestamp, which later can be made relative to the start of any recording happening during that time

# clean up: close the ChucK shell when done
def close():
    send_command("chuck --kill")  # Send a kill command if needed
    process.terminate()
    process.wait()

'''
while(True):
    output = read_output()
    for line in output:
        print(line)
    time.sleep(1)
'''

'''chuckShell.py'''