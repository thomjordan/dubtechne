# %% [interactive]
fauckPhiEnv(oct=0, pulse=4)

# %%
slicing()

# %%

xss(2)

# %%
get_samples_since_VM_start()

# %%
import redis
redis = redis.Redis(host='76.18.119.54', port=6379, decode_responses=True, password='CloseToTheEdge')

print(redis.keys("*"))

# redis.set("hello_friend", "This is really cool!")
print(redis.get("hello_friend"))
print(redis.get("start_timestamp"))

# %%
sc("^")

# %%
xs('fauckPhiEnv')

# %%

sc("{4 => octave;}")

# %%
[ us(id) for id in fauckPhiEnv ]

# %%

yo = 5

da = eval(f'{yo}')

da + da 

# %%
def xss(n): [ xs(id+1) for id in range(n) ]

[ print(id+1) for id in range(2) ]

# %%
foo = 5
print('Yo!', foo)

# %%

print(f'the answer is {5 if False else "hoot!"}')
#print(f'the answer is {yo}')

# %%
arr = [1, 2, 3]

print(f'arr has {len(arr)} elements: {arr}')

print(len(arr) * 1000)

if isinstance(arr, list):
    print("arr is a list.")
else:
    print("arr is not a list.")
# %%
foo = 5; bar = 6
foo + bar

# %%

arr = [1, 2, 3]

print(f"\'{arr}\' has {len(arr)} shreds on its stack: {arr} <-- (top of the stack)")
# %%

from varname import varname

def func():
  return varname()

# In external uses
xwow = func() # 'x'
y = func() # 'y'

x = xwow 
print(x)

def ho(aname):
    try:
        _ = aname
    except:      
        print(f"ERROR: it doesn't exist")
        return

ho(yo)


# %%

from collections import UserList

class MyList(UserList):
    def __init__(self, data, **attrs):
        super().__init__(data)
        self.__dict__.update(attrs)

my_array = MyList([1, 2, 3], name="my_array")

print(my_array)        
print(my_array.name)   

my_array += [4, 5, 6, 7, 8]
my_array.name = "my_bigger_array"

print(my_array)         
print(my_array.name)   

print(isinstance(my_array, MyList)) 

print(my_array[-8])
print(len(my_array))

print(my_array.pop(-3))
print(my_array.pop(-5))
print(my_array)         
print(my_array.name)

# %%

str(yo)


# %%

print(isinstance(5, int))


# %%

class CubeCalculator:
    def __init__(self, function):
        self.function = function

    def __call__(self, *args, **kwargs):

        # before function
        print("calling", self.function.__name__, "with input arg", args[0])
        print(type(self.function.__name__))

        # function (decoratee) called
        result = self.function(*args, **kwargs)

        # after function
        print("double the arg is:", args[0]*2)

        return result

# adding class decorator to the function
@CubeCalculator
def get_cube(n):
    print("Input number:", n)
    return n * n * n

print("Cube of number:", get_cube(100))

# %%

def make_ChucK_arglist(args_dict):
    arglist = ''
    for key in args_dict:
        arglist += f':{args_dict[key]}'
    return arglist 

class ChucKManagedFileShred:
    def __init__(self, function):
        self.function = function

    def __call__(self, *args, **kwargs):
        # before function call
        name = self.function.__name__

        kwdefaults = self.function.__kwdefaults__
        unified_params = kwdefaults

        print(kwdefaults)
        print(kwargs)

        for key in kwargs:
            unified_params[key] = kwargs[key]

        print(unified_params)
        arglist = make_ChucK_arglist(unified_params)

        print(arglist)

        # function (decoratee) called
        result = self.function(*args, **kwargs)

        # after function
        return result

    
@ChucKManagedFileShred
def testCMFS(*, oct=0, pulse=8, scale=1): () 


testCMFS(oct=7, pulse=16)


# %%
yo = ShredsList([], name='yo')
print(type(yo) is ShredsList)

foo = dict(name='_yo_', contents=yo)
print('name' in foo.keys())

# %%
