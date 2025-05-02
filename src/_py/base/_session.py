# %% [interactive]
fauckPhiEnv(oct=2, pulse=16)

# %%
slicing()

# %%
xss(5)

# %%
print(shared_vars["slicing"])

# %%
sc("{ <<< me.sourceDir() >>>; }")

# %%
import redis
# redis = redis.Redis(host='76.18.119.54', port=6379, decode_responses=True, password='CloseToTheEdge')
redis = redis.Redis(host='127.0.0.1', port=6379, decode_responses=True)

print(redis.keys("*"))
print('start_timestamp:', redis.get("start_timestamp"))

# %%
sc("^")

# %%
xs('fauckPhiEnv')

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
)
f(8)

# %%
f = lambda x, a = 1 : [ a := a * b for b in range(1, x+1) ][-1]
f(8) #/ 5760.0
# %%
362880.0 / 720.0

# %%
import re
import codecs
import encodings
import functools


def defify(txt):
    first, rest = txt.split('\n', maxsplit=1)
    _, fname, args = re.findall(r"((\w+)\s*=\s*)?lambda\s*(.*)\s*:", first).pop()
    return f"def {fname or '_'}({args}):\n" + rest


def transform(string, decode_mode):
    if isinstance(string, bytes):
        string = string.decode("utf-8")
    txt = string.splitlines(keepends=True)[::-1]
    length = len(txt)
    lines = ""

    while txt:
        lambda_buffer = []
        line = txt.pop()
        line = line.replace('λ', "lambda")

        if newlined_lambda := re.search(r"lambda.*:\s*\n", line):
            lambda_buffer = [line]
            header = line # to keep track of lambda's definition line contents
            lambda_start, _ = newlined_lambda.span()

            assert txt, "Unexpected EOF"
            line = txt.pop()

            lfspaces = re.search(r"(\s*)", line)
            assert lfspaces
            spaces = lfspaces.group()

            while line.startswith(spaces):
                lambda_buffer.append(line)
                lines += "\n" # here i push newlines to make up for loss of lines when inlining the lambda call,
                              # otherwise exception traceback would show wrong line number
                if not txt:
                    break
                line = txt.pop()

            transformed = header[:lambda_start] + f"type(lambda:1)(compile({repr(defify(''.join(lambda_buffer)))}, '<preprocessed lambda>', 'single').co_consts[0], globals())\n"
            lines += transformed + line

        else:
            if re.search(r"lambda.*:\s*return .*\n", line):
                line = re.sub("return", "", line)

            elif re.search(r"lambda.*:\s*yield .*\n", line):
                line = re.sub(r"yield (.*)", r"(yield \1)", line)

            lines += line

    return (lines, length) if decode_mode else bytes(lines, 'utf-8')


decoder = functools.partial(transform, decode_mode=True)
encoder = functools.partial(transform, decode_mode=False)


class IncrementalDecoder(encodings.utf_8.IncrementalDecoder):
    def decode(self, string, final=False):
        self.buffer += string
        if final:
            buffer = self.buffer
            self.buffer = b""
            return super().decode(encoder(buffer))
        return ""


def superlambda_codec(encoding):
    if encoding == "superlambda":
        return codecs.CodecInfo(
            name="superlambda",
            encode=encodings.utf_8.encode,
            decode=decoder,
            incrementaldecoder=IncrementalDecoder,
        )

codecs.register(superlambda_codec)

#'''
m = lambda n: (
    if n == 1:
        return n
    return n * m(n-1))
#'''
# %%

val = 0

msg = "ON" if val else "OFF"

print(msg)


# %%

True + True * False
# %%
