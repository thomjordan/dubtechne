# %% [interactive]
from chucKShell import *
await main()
await asyncio.sleep(3)
importBase("Globals")
await asyncio.sleep(3)
sc("get_vm_start_time()")
print_to_jupyter("Yipee!!")

#%%
setTempo(100, launchQ=8)

# %% 
fauckPhiEnv(oct=0, pulse=8, vol=100)

# %% 
fauckPhiEnv(oct=3, pulse=16, vol=100)

# %% 
xs('fauckPhiEnv')

# %%
slicing()

# %%
xss(20)

#%%
send_command("- 1")

#%%
xs('slicing')

#%%
sc("{ <<< t.tempo >>>; }")
#%%
sc("{ <<< t.syncPeriod >>>; }")
#%%
sc("{ <<< t.startTime >>>; }")
#%%
sc("{ <<< now >>>; <<< now + 1::second >>>; }")
#%%
sc("{ t.setTempo(90.0); }")
#%%
sc("{ t.setTempo(120.0); }")
#%%
sc("{ t.setLaunchQ(2); }")
#%%
sc("{ t.setLaunchQ(4); }")
#%%
print(shared_vars["slicing"])

# %%
sc("{ <<< me.sourceDir() >>>; }")

# %%
sc("{4 => octave;}")

# %%
[ xs(id) for id in vars['slicing']]

# %%
class ParametricContext:
    def __init__(self, *args, **kwargs):
        self.args = args
        self.kwargs = kwargs

    def __call__(self, lambdafunc):
        return lambdafunc(*self.args, **self.kwargs) # [-3]

foo = ParametricContext(2, 3, 5)(lambda w, x, y: (
    a := (w * x)**y,
    z := w + x + y,
    x * z 
))

bar = ParametricContext(2, 4, 6)

print(foo)
print(bar(lambda a, b, c :( a**b**c )))

# %%
f = lambda x : (
    x * f(x-1) 
    if x != 1 
    else 1
)# %%

sc('{ @import \\"/home/subhan/dev/dubtechne/src/chucK/base/Globals.ck\\" }')

f(8)

# %%
f = lambda x, a = 1 : [ a := a * b for b in range(1, x+1) ][-1]
f(8) #/ 5760.0

# %%

sc('{ @import \\"/home/subhan/dev/dubtechne/src/chucK/base/Globals.ck\\" }')


# %%
