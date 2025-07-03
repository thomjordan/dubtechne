import subprocess
import threading
import asyncio
import errno
import pty
import os
import re
import sh
import time
from collections import UserList
from IPython.display import display, Markdown

# Linux
chucK_base_dir = "/home/subhan/dev/dubtechne/src/chucK/base/"
chucK_play_dir = "/home/subhan/dev/dubtechne/src/chucK/play/"
sample_rate = 48000 

# Regex to clean ANSI escape sequences
ansi_escape = re.compile(r'\x1b\[[0-9;]*m')

# Globals for your processes and fifo writer
chuck_process = None
pwcat_process = None

async def read_chuck_stderr(process):
    while True:
        line = await process.stderr.readline()
        if not line:
            break
        line = line.decode('utf-8', errors='replace').rstrip()
        cleaned_line = ansi_escape.sub('', line)
        if cleaned_line:
            # Your processing functions here
            check_for_launched_shred_and_retain_id(cleaned_line)
            check_for_removed_shred_and_remove_its_id_from_shredlist(cleaned_line)
            check_for_ChucK_start_time_and_update_Globals(cleaned_line)
            print_to_jupyter(cleaned_line)

async def launch_chuck_subprocess():
    global chuck_process, pwcat_process

    # Create a pipe for audio from chuck -> pw-cat
    r_fd, w_fd = os.pipe()

    # Wrap file descriptors with file objects (unbuffered binary mode)
    r_file = os.fdopen(r_fd, 'rb', buffering=0)
    w_file = os.fdopen(w_fd, 'wb', buffering=0)

    # Launch pw-cat: read raw audio from r_file
    pwcat_process = await asyncio.create_subprocess_exec(
        "pw-cat",
        "-p", "-a",
        "--rate", "48000",
        "--channels", "2",
        "--format", "s32",
        "-",
        stdin=r_file
    )

    # Launch chuck-stdout: write raw audio to w_file, capture stderr
    chuck_process = await asyncio.create_subprocess_exec(
        "stdbuf", "-o0", "-eL",
        "/home/subhan/ext/chuck/src/host-examples/chuck-stdout",
        stdin=asyncio.subprocess.PIPE,
        stdout=w_file,
        stderr=asyncio.subprocess.PIPE
    )

    # Close file objects in parent to avoid FD leaks (subprocess owns them)
    r_file.close()
    w_file.close()

    # Start asynchronous reading of stderr logs
    asyncio.create_task(read_chuck_stderr(chuck_process))

    # Wait briefly for chuck-stdout to open FIFO
    await asyncio.sleep(0.5)

    print("ChucK and pw-cat subprocesses launched")


# function for printing to interactive window
def print_to_jupyter(line):
    """Print to Jupyter/VSCode interactive window."""
    display(Markdown(f"`{line}`"))


# namespace for sharing data between threads
vars = {}


class ShredsList(UserList):
    """For maintaining a list of active ChucK shreds associated with the same .ck file 

    All shreds in the list are currently-playing instances of the same .ck file (a.k.a. the 'host'). 
    It's worth noting that any child shreds sporked from WITHIN said file are not included in list, 
      as their life-cycles are automatically managed by the parent.

    The name of the host file can be stored as metadata on the list, via the '.name' property:

    >> active_shreds = ShredsList([1, 2, 3], name="someChuckFile")

    >> print(active_shreds)       --> [1, 2, 3]

    >> print(active_shreds.name)  --> "someChuckFile"
    
    Each time the same ChucK file is launched, a new shred_id gets added to the list associated with said file.
    A shred_id is removed from the list when its associated shred is removed from the VM's queue of actively-playing shreds.
    """

    def __init__(self, data, **attrs):
        super().__init__(data)
        self.__dict__.update(attrs)


def extract_shred_id_and_filename_for_launched_shred(line):
    sporked_shred_pattern = re.compile(r"\(VM\) sporking incoming shred: (\d+) \((.+)\.ck\)")
    match = sporked_shred_pattern.search(line)
    # returns (shred_id, filename_without_ext) if a match is found
    if match: 
        shred_id = int(match.group(1))
        filename = match.group(2)
        print_to_jupyter(f'shred_id {shred_id} returned for newly-launched file: {filename}.ck')
    return (shred_id, filename) if match else None

def check_for_launched_shred_and_retain_id(line):
    maybe_data = extract_shred_id_and_filename_for_launched_shred(line)
    if not(maybe_data): return
    (shred_id, filename) = maybe_data 
    # since shred_id exists, we take steps below to store it in a pragmatically useful and meaningful way
    # print_to_jupyter(f"Sporking file \'{filename}.ck\' returned shred_id [{shred_id}]")
    # launching the filename successfully sporked a shred
    # so we check if key exists in shared_vars 
    # if it doesn't, we make a new (k,v) entry: a LIFO with filename as key
    ensure_LIFO_exists_at_key(filename)
    # we push shred_id onto "the top of the stack" (i.e. we append it to the back of the LIFO array)
    vars[filename] += [shred_id]
    print_to_jupyter(f'{vars[filename]} => {filename}')

def extract_shred_id_and_filename_for_removed_shred(line):
    removed_shred_pattern = re.compile(r"\(VM\) removing shred: (\d+) \((.+)\.ck\)")
    match = removed_shred_pattern.search(line)
    # returns (shred_id, filename_without_ext) if a match is found
    if match: 
        shred_id = int(match.group(1))
        filename = match.group(2)
        # print_to_jupyter(f'shred_id {shred_id} returned for newly-launched file: {filename}.ck')
    return (shred_id, filename) if match else None

def check_for_removed_shred_and_remove_its_id_from_shredlist(line):
    if not(removing_shred_directly_by_id): return 
    maybe_data = extract_shred_id_and_filename_for_removed_shred(line)
    if not(maybe_data): return
    (shred_id, filename) = maybe_data
    print_to_jupyter(f'removed shred_id {shred_id} directly, from {filename}\'s shredlist')
    vars[filename].remove(shred_id)

def check_for_ChucK_start_time(line):
    pattern = r"^VM start time in microseconds:\s*(\d+)"
    #line = "VM start time in microseconds: 1751485612216381"
    match = re.search(pattern, line)
    if match:
        print_to_jupyter(f"Matched!: {match.group(1)}")
        return match.group(1)
    else:
        return None

# assumes that importBase("Globals") has already been called (the file in which class 't' is defined)
def check_for_ChucK_start_time_and_update_Globals(line):
    vm_start_in_microseconds = check_for_ChucK_start_time(line) 
    if vm_start_in_microseconds:
        vm_start_time_in_samples = float(vm_start_in_microseconds) / 1000000.0 * sample_rate
        update_startTime_command = '{ ' + f'{vm_start_time_in_samples} => t.startTime;' + ' }'
        send_command(update_startTime_command)
        print_to_jupyter(f' VM start time in samples: {vm_start_time_in_samples}')

test_command = "/home/subhan/dev/dubtechne/src/chucK/play/fauckPhiEnv.ck:1:4:8:1:100"

async def send_command_async(command: str):
    await asyncio.create_subprocess_shell(
        f'echo "{command}" > /tmp/chuck_cmd'
    )

def send_command(command: str):
    """Run an async FIFO echo command from a synchronous context."""
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)

    if loop.is_running():
        asyncio.create_task(send_command_async(command))
    else:
        loop.run_until_complete(send_command_async(command))

def run_async_anywhere(func, *args, **kwargs):
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)

    if loop.is_running():
        asyncio.create_task(func(*args, **kwargs))
    else:
        loop.run_until_complete(func(*args, **kwargs))

def import_chuck_file(fullpath: str):
    send_command('{ @import \\"' + f'{fullpath}' + '\\" }')

def print_ChucK_stats():
    """Prints ChucK stats such as the value of 'now' (number of samples since VM started)"""
    send_command("^")

'''
async def async_exit():
    send_command("exit")
    global chuck_process, pwcat_process
    if chuck_process:
        chuck_process.terminate()
        await chuck_process.wait()
        chuck_process = None
    if pwcat_process:
        pwcat_process.terminate()
        await pwcat_process.wait()
        pwcat_process = None

#def exit():
#    run_async_anywhere(async_exit)
'''

def exit_():
    send_command("exit")

# Example: Load a simple sine oscillator script in real-time
# send_command("{ 1::second => dur T; SinOsc s => dac; while (true) { T => now; } }")
# send_command("+ mesh2Dexample.ck")

# make a shortcut 
sc = send_command

def make_ChucK_arglist(voice_num, args_dict):
    """Since ChucK files can be launched with any specified set of input arguments, this function constructs the argument list 
    for appending onto a ChucK filename when launching said file as a shred.
    
    voice_num: an int specifying the number-of-shreds-of-this-file-already-playing, plus one.
    This value can be considered the shred's 'voice num' w.r.t. the file, to distinguish it from other currently-playing instances of the same file.
    
    args_dict: a dictionary holding the argument values, added in the order that the ChucK file expects them."""

    arglist = f':{voice_num}'
    for key in args_dict:
        arglist += f':{args_dict[key]}'
    return arglist 

class ChucKManagedFileShred:
    """This class provides a decorator for functions which launch specific .ck files.
    
    All one needs to do is:
    - create an empty function, whose name is identical to the .ck file it will be expected to launch upon invocation.
    - if the .ck file expects arguments, specify these as kwargs with default values, in the same order that the .ck file expects them.

    Then, when calling the function, one can supply any number of the specified keyword-args in any order, and this decorator class will launch the file with
    its full list of expected arguments, using the default values for any remaining keyword-args not explicity provided in the function call.
    """

    def __init__(self, function):
        self.function = function

    def __call__(self, *args, **kwargs):
        # << before function call >>
        # since by convention, these file-launch functions are named after ChucK files,
        # we assume that this is the case
        chuck_filename = self.function.__name__

        # if a ShredList doesn't already exist at key, make one
        ensure_LIFO_exists_at_key(chuck_filename)
        numshreds_in_list = get_LIFO_current_size(chuck_filename)

        # we assign a voice_num based on how many shreds are currently playing for filename,
        #   shreds that were launched directly by sending "+ {filename}" to the ChucK shell
        voice_num = numshreds_in_list + 1

        kwdefaults = self.function.__kwdefaults__
        unified_params = kwdefaults

        #print_to_jupyter(kwdefaults)
        #print_to_jupyter(kwargs)

        for key in kwargs:
            unified_params[key] = kwargs[key]

        #print_to_jupyter(unified_params)

        # create a formatted arg string from voice_num and unified_params
        argstr = make_ChucK_arglist(voice_num, unified_params) if unified_params else ()  

        print_to_jupyter(f'+ {chuck_filename}.ck{argstr}')

        # spork the file with args
        spork(chuck_filename, argstr) 

        # finally, call function (decoratee), in case it contains its own statements
        result = self.function(*args, **kwargs)

        # << after function call >>
        return result

# ensure {symbol} evaluates to a LIFO (last in, first out) data-structure
def ensure_LIFO_exists_at_key(filename):
    # if 'filename' is already defined, then we don't need to construct anything, and we can exit the function
    if filename in vars: return
    # if 'filename' desn't exist yet, we construct it..
    # ..assigning to it an empty ShredsList in the shared_vars namespace 
    #print_to_jupyter(f"LIFO created for \'{filename}\'")
    vars[filename] = ShredsList([], name=filename)

def get_LIFO_current_size(filename):
    # based on how (and where) this function is used,
    #  these next two lines should always be false; they are only included here for safety
    if not(filename in vars.keys()): return None
    if not(type(vars[filename]) is ShredsList): return None
    return len(vars[filename])

def spork(filename, args=None):
    args = args if args else ''
    spork_file_command = f'send_command(\"+ {chucK_play_dir}{filename}.ck{args}\")'
    eval(spork_file_command)

# removing_shred_directly_by_id - a flag that indicates whether we are removing a shred directly by its id,
#  or alternately, by its place in the host filename's shredlist (LIFO stack)
# If the former, we must manually remove its id from the filename's shredlist, 
#  by parsing the ChucK output that says that a shred has been removed.
# If the latter, the xs() function will remove the shred based on its position in the stack, and not by its id.
# In this case, the flag will ensure that the ChucK output will not trigger a removal, since it has already been done
removing_shred_directly_by_id = True 

def xs(arg, position=0):
    """Cancels shred, either directly by shred_id, or by position in the host filename's shredlist stack.
    
    arg: either the explicit shred_id to cancel (int), or the name of the .ck file 
    from whose ShredList we wish to remove the shred from, based on its position in the stack.

    position: only relevant when arg is a str representing a .ck filename, this int value specifies the position 
    from the back of the filename's associated ShredList (i.e. the 'top of the stack'), where the 0th position 
    removes the most-recently-launched shred from said filename, the 1st position removes the second most-recently-launched shred, et al.
    """

    global removing_shred_directly_by_id
    # we can remove the shred by directly providing its shred_id... 
    if isinstance(arg, int): 
        removing_shred_directly_by_id = True 
        shred_id = arg
        send_command(f'- {shred_id}')
        return
    # ...or we can remove it by providing its host's filename and position on the host's shredlist stack (relative to when it was launched)
    # in this case, since arg is not an int we can assume it's a string: the name of the .ck file that the shred is playing (a.k.a. its "host")
    ck_filename = arg
    removing_shred_directly_by_id = False 
    # we know that an entry in shared_vars has been created with this host filename as key, that is mapped to a list of playing shreds
    # we retrieve that list as local variable 'list_of_shreds':
    list_of_shreds = vars[ck_filename] 
    
    if not(isinstance(list_of_shreds, ShredsList)):
        print_to_jupyter(f"ERROR: {list_of_shreds.name} is not a ShredsList")
        return
    elif len(list_of_shreds) == 0:
        print_to_jupyter(f"{list_of_shreds.name} has no more shreds to remove, it is an empty list")
        return
    else:
        if position >= len(list_of_shreds):
            print_to_jupyter(f"ERROR: {list_of_shreds.name} has only {len(list_of_shreds)} shreds, index {position} is out-of-bounds")
            return
        else:  # remove the shred that is 'nthpop' places from the back of the list (i.e. the top of the stack)
            send_command(f"- {list_of_shreds[-(position+1)]}")
            #removed_shred_id = list_of_shreds.pop(-(nthpop+1))
            list_of_shreds.pop(-(position+1))
            #print_to_jupyter(f"Shred {removed_shred_id} was removed from the \'{list_of_shreds.name}\' playstack")
            num_shreds_remaining = len(list_of_shreds)
            if num_shreds_remaining > 0:
                print_to_jupyter(f"{list_of_shreds} <- {list_of_shreds.name} has {len(list_of_shreds)} shreds left on its stack")
            else:
                print_to_jupyter(f"{list_of_shreds.name} has no more active shreds on its stack")

# TODO: add logging, and if possible, a way to supply a dictionary of parameter values for that sporking, 
#   then also have it archive those settings as a .json file with a timestamp, which later can be made relative to the start of any recording happening during that time

def xss(n): 
    """Removes the first n shred_ids from the VM."""
    [ xs(id+1) for id in range(n) ]

def exit():
    """Cleans up and closes the ChucK shell when done."""
    send_command("exit")
    chuck_process.terminate()
    chuck_process.wait()

def importBase(filename):
    filepath_string = f'{chucK_base_dir}{filename}.ck'
    import_chuck_file(filepath_string)
    #command = '{ ' +  f'@import "{filepath_string}"' + ' }'
    #send_command(command)
    #display(command)

# sets global tempo of ChucK, with optional launchQuantization window_size (in num_beats)
def setTempo(bpm, launchQ=None):
    if launchQ:
        command = '{ t.setTempo(' + str(bpm) + ', ' + str(launchQ) + '); }'
    else:
        command = '{ t.setTempo(' + str(bpm) + '); }'
    send_command(command)

# display confirmation message that the ChucK subprocess started successfully
display(Markdown("✅  **ChucK subprocess started**  ✅"))

# programmatically decorate all functions in 'chucKLaunchableFiles.py':
from chucKLaunchableFiles import *

def get_list_of_launchable_file_func_names():
    """Returns a list of names of functions defined in chucKLaunchableFiles.py"""

    grep = sh.Command('grep')
    funcs_str = grep('^def', 'chucKLaunchableFiles.py')
    funcs_raw_strings_list = funcs_str.split(':')
    extract_funcs_pattern = re.compile(r"def (\w+)\(")
    func_names_list = []
    for f in funcs_raw_strings_list:
        match = extract_funcs_pattern.search(f)
        if match: func_names_list.append(match.group(1))
    return func_names_list

def get_statements_to_decorate_launchable_file_funcs():
    """Returns a list of statements to execute, for programmatically adding the 'ChucKManagedFileShred' decorator to
    each function in 'chucKLaunchableFiles.py'. 
    
    Since exec() does not seem to work within a loop within a function, we need to explicity create a list of the code 
    statements we need, then execute them by using exec() in a top-level loop.
    
    Why go to all this trouble simply to add this decorator? 
    
    This allows us to create functions for launching specific .ck files, just once in 'chucKLaunchableFiles.py', and 
    this will add the decorator programmatically to all functions in that file. This, combined with the functionality 
    added with the ChucKManagedFileShred decorator (only needing to specify the function name and signature, where the 
    decorator does all the heavy-lifting), provides a super-lightweight way to launch .ck files based only upon the
    file's name (derived from the function's name), and the function's signature which specifies keyword args and default values.
    """

    func_names = get_list_of_launchable_file_func_names()
    statements = []
    for func_name in func_names:
        statements.append( f"{func_name} = ChucKManagedFileShred({func_name})" )
    return statements

statements_to_execute = get_statements_to_decorate_launchable_file_funcs() 
for s in statements_to_execute: exec(s)


async def main():
    await launch_chuck_subprocess()

