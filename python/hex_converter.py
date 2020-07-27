def get_hex(number):
    return hex(number).lstrip("0x").zfill(4)

def calc_checksum_two(a):
    return hex((((sum(int(a[i:i+2],16) for i in range(0, len(a), 2))%0x100)^0xFF)+1)&0xFF)[2:].zfill(2)

f = open('program2.hex', 'w')

program_in_ascii = input()

some_dict = {
    ">": 1,
    "<": 2,
    "+": 3,
    "-": 4,
    ".": 5,
    ",": 6,
    "[": 7,
    "]": 8
}
program_in_numbers = list(map(lambda symb: some_dict[symb], list(program_in_ascii)))

for i in range(0, len(program_in_numbers)):
    message = "01%s%s" % (get_hex(i), get_hex(program_in_numbers[i]))
    f.write((":" + message + calc_checksum_two(message) + "\n").upper())

for i in range(len(program_in_numbers), 1024):
    message = "01%s0000" % get_hex(i)
    f.write((":" + message + calc_checksum_two(message) + "\n").upper())
f.write(':00000001FF\n')
f.close()

