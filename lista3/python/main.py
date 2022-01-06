import ply.yacc as yacc
import ply.lex as lex

n = 1234577
notation = []
error = False

tokens = (
    'NUM', 'LB', 'RB', 'END',
    'ADD', 'SUB', 'MUL', 'DIV', 'POW',
)

t_NUM = r'[0-9]+'
t_ADD = r'\+'
t_SUB = r'-'
t_MUL = r'\*'
t_DIV = r'/'
t_POW = r'\^'
t_LB = r'\('
t_RB = r'\)'
t_END = r'\n'
t_ignore = ' \t'
t_ignore_COMMENT = r'\#(.|\\\n)*\n'
t_ignore_SLASH = r'\\\n'


def t_error(t):
    notation.clear()
    global error
    error = True
    f2.write("incorrect character\n")
    t.lexer.skip(1)
    return t


lexer = lex.lex()

precedence = (
    ('left', 'ADD', 'SUB'),
    ('left', 'MUL', 'DIV'),
    ('nonassoc', 'POW'),
    ('right', 'NEG'),
)


def p_input(t):
    """input :
                | input line"""
    pass


def p_line_error(t):
    """line : error END"""
    global error
    error = False
    notation.clear()


def p_line(t):
    """line : END
                | exp END"""
    global error
    if not error:
        for i in notation:
            f2.write(i)
        f2.write(f"\nresult: {t[1]}\n")
        notation.clear()


def p_exp_binop(t):
    """exp : exp ADD exp
                | exp SUB exp
                | exp MUL exp
                | exp DIV exp
                | exp POW power1"""
    if t[2] == '+':
        notation.append("+ ")
        t[0] = (t[1] + t[3]) % n
    elif t[2] == '-':
        notation.append("- ")
        t[0] = t[1] - t[3]
        if t[0] < 0:
            t[0] += n
    elif t[2] == '*':
        notation.append("* ")
        t[0] = t[1] * t[3] % n
    elif t[2] == '/':
        if t[3] == 0:
            global error
            error = True
            f2.write("cannot divide by zero\n")
            t[0] = 0
            return
        notation.append("/ ")

        t[0] = t[1] * reci(t[3]) % n
    elif t[2] == '^':
        notation.append("^ ")
        t[0] = pow(t[1], t[3], n)


def p_exp_neg(t):
    """exp : SUB exp %prec NEG"""
    t[0] = n - t[2]
    notation[len(notation) - 1] = f"{t[0]} "


def p_exp_num(t):
    """exp : NUM"""
    t[0] = int(t[1]) % n
    notation.append(f"{t[0]} ")


def p_exp_group(t):
    """exp : LB exp RB"""
    t[0] = t[2]


def p_power1_neg(t):
    """power1 : SUB power1 %prec NEG"""
    if t[2] != 0:
        result = (n - 1) - t[2]

        notation[len(notation) - 1] = str(result)
        t[0] = result
    else:
        t[0] = 1


def p_power1_num(t):
    """power1 : NUM"""
    t[0] = int(t[1]) % n
    notation.append(f"{t[0]} ")


def p_power1_group(t):
    """power1 : LB power2 RB"""
    t[0] = t[2]


def p_power2_num(t):
    """power2 : NUM"""
    t[0] = int(t[1]) % n
    notation.append(f"{t[0]} ")


def p_power2_div(t):
    """power2 : power2 DIV power2"""

    global n
    global error
    if t[3] != 0:
        if NWD(t[3], n - 1) == 1:
            n -= 1
            x = reci(t[3])
            n += 1
            result = t[1] * x % (n - 1)

            notation[len(notation) - 1] = str(result)
            t[0] = result
        else:
            error = True
            f2.write("incorrect number in cyclic group\n")
            t[0] = 0
            return
    else:
        error = True
        f2.write("cannot divide by zero\n")
        t[0] = 0
        return

    notation.append("/ ")


def p_power2_add(t):
    """power2 : power2 ADD power2"""

    result = (t[1] + t[3]) % (n - 1)
    notation[len(notation) - 1] = str(result)
    t[0] = result
    notation.append("+ ")


def p_power2_sub(t):
    """power2 : power2 SUB power2"""

    result = t[1] - t[3] - 1
    if result < 0:
        result += n

    notation[len(notation) - 1] = str(result)
    t[0] = result
    notation.append("- ")


def p_power2_mul(t):
    """power2 : power2 MUL power2"""

    result = t[1] * t[3]

    notation[len(notation) - 1] = str(result)
    t[0] = result
    notation.append("* ")


def p_error(t):
    notation.clear()
    global error
    if not error:
        error = True
        f2.write("syntax error\n")


def NWD(a, b):
    while a != b:
       if a > b:
           a -= b
       else:
           b -= a
    return a


def reci(a):
    u = 1
    w = a
    x = 0
    z = n
    while w != 0:
        if w < z:
            q = u
            u = x
            x = q
            q = w
            w = z
            z = q
        q = int(w / z)
        u -= q * x
        w -= q * z

    if x < 0:
        x += n
    return x


parser = yacc.yacc()

f = open("data.txt", 'r')
lines = f.readlines()
f.close()

f2 = open("converted.txt", "w")
txt = ""
for line in lines:
    txt += line

parser.parse(txt)
f2.close()
