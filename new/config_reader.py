import sys


dictionary = dict()
with open("new/oneDNA2pileup", "r") as file:
    for line in file:
        variable_name = ""
        value = ""
        entered_value = False
        for char in line:
            if char == "#" or char == "\n":
                break
            if char == "=":
                if entered_value == False:
                    entered_value = True
                    continue
                else:
                    raise ValueError("Two assignments in one line!")
            if entered_value:
                value += char
            else:
                variable_name += char
        if variable_name:
            dictionary[variable_name.strip()]=value.strip()
for i in range(1,len(sys.argv)):
    print(dictionary[sys.argv[i]])


