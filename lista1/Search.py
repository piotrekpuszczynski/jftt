class Search:
    def __init__(self, pattern, file):
        self.pattern = pattern

        file = open(file, "r")
        self.lines = file.readlines()
        file.close()

    def search(self, line):
        pass

    def execute(self):
        for line in self.lines:
            self.search(line)


class FiniteAutomation(Search):
    def __init__(self, pattern, file):
        super().__init__(pattern, file)

        self.alphabet = []
        for line in self.lines:
            for i in line:
                if i not in self.alphabet:
                    self.alphabet.append(i)

        self.transition = [[0 for _ in range(len(self.alphabet))] for _ in range(len(self.pattern) + 1)]

        chars = len(self.alphabet)
        for state in range(len(self.pattern) + 1):
            for x in range(chars):
                self.transition[state][x] = self.getState(state, x)

    def getState(self, state, x):

        if state < len(self.pattern) and x == self.alphabet.index(self.pattern[state]):
            return state + 1

        for nextState in range(state, 0, -1):
            if self.alphabet.index(self.pattern[nextState - 1]) == x:

                i = 0
                while i < nextState - 1:
                    if self.pattern[i] != self.pattern[state - nextState + 1 + i]:
                        break
                    i += 1
                if i == nextState - 1:
                    return nextState
        return 0

    def search(self, line):

        state = 0
        for i in range(len(line)):
            state = self.transition[state][self.alphabet.index(line[i])]
            if state == len(self.pattern):
                print("pattern found at index: ", str(i - len(self.pattern) + 1), " in line: ", self.lines.index(line))


class KnuthMorrisPratt(Search):
    def __init__(self, pattern, file):
        super().__init__(pattern, file)
        self.lps = [0] * len(self.pattern)

        i = 1
        length = 0
        while i < len(self.pattern):
            if self.pattern[i] == self.pattern[length]:
                length += 1
                self.lps[i] = length
                i += 1
            else:
                if length == 0:
                    self.lps[i] = 0
                    i += 1
                else:
                    length = self.lps[length - 1]

    def search(self, line):

        i = 0
        j = 0
        while i < len(line):
            if self.pattern[j] == line[i]:
                i += 1
                j += 1

            if j == len(self.pattern):
                print("pattern found at index: ", str(i - j), " in line: ", self.lines.index(line))
                j = self.lps[j - 1]
            elif i < len(line) and self.pattern[j] != line[i]:
                if j != 0:
                    j = self.lps[j - 1]
                else:
                    i += 1
