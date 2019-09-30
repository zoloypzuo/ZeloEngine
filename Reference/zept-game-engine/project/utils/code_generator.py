def read_lines():
    with open('doc.txt', 'r') as f:
        text = f.read()
        lines = text.splitlines(keepends=True)
        # print(lines)
        return lines


def join(strs: list):
    return ''.join(strs)


def new_long_str(s: str):
    return "\'\'\'{0}\'\'\'".format(s)


def new_region(region_name: str, region_content: str):
    return join(['# region %s\n' % region_name, region_content, '# endregion\n'])


def new_variable(var_name, doc):
    return '%s=0  # %s' % (var_name, doc)


def add_tab(s):
    return '\t' + s


def new_class(class_name: str, class_content: str, base_class_names=('',)):
    code = ['class %s(%s):\n' % (class_name, ','.join(base_class_names))] \
           + [add_tab(line) for line in class_content.splitlines(keepends=True)] + ['\n']
    return join(code)


def new_function(func_name: str, arg_names: list, doc: str, body: str = 'pass'):
    code = ['def %s(%s):\n' % (func_name, ', '.join(arg_names)),
            # 'def {}({}):\n'.format(method_name, ', '.join(arg_names)
            add_tab(new_long_str(doc.strip())), '\n',
            add_tab(body + '\n')]
    return join(code)


def new_method(method_name: str, arg_names: list, doc: str, body: str = 'pass'):
    return new_function(method_name, ['self'] + arg_names, doc, body)


def new_property(property_name: str, doc: str):
    return '@property\n' + new_method(property_name, [], doc)


def new_static_method(method_name: str, doc: str):
    return '@staticmethod\n' + new_function(method_name, [], doc)


def split_name_doc(line):
    return line.split('\t', maxsplit=1)


import re


def unity_doc():
    lines = read_lines()
    class_name = lines[0].strip()
    class_tag = lines[1].replace('Other VersionsLeave feedback',
                                 '')  # class in UnityEngine/Inherits from:Component/Implemented in:UnityEngine.CoreModuleOther VersionsLeave feedback
    base_class_name = ''
    path = ''
    import re
    match_obj = re.search('Inherits from:(.*?)/', class_tag)
    if match_obj:
        base_class_name = match_obj.group(1)
    match_obj = re.search('Implemented in:UnityEngine\.(.*)', class_tag)
    if match_obj:
        path = 'ZeptUnityEngine/' + match_obj.group(1).replace('.', '/')
    lines = lines[2:]
    parts = ['Description', 'Static Properties', 'Properties',
             'Constructors', 'Public Methods', 'Static Methods',
             'Operators', 'Inherited Members','Messages']
    parts = [i for i in parts if i + '\n' in lines]  # some doc pages do not have all parts, so ...
    part_indexes = [lines.index(part + '\n') for part in parts] + [
        len(lines)]  # note that the tail is appended and '\n' is appended
    generated_code = []
    class_content = []
    for index, part in enumerate(parts):
        part_start_index = part_indexes[index]
        part_end_index = part_indexes[index + 1]
        part_content = lines[part_start_index + 1:part_end_index]  # +1 to skip part name line
        if part == 'Description':
            strs = [class_tag] + ['Description\n'] + \
                   [re.sub('\. ', '.\n', line) for line in part_content]
            generated_code.append(new_long_str(join(strs).strip()) + '\n')
        elif part == 'Static Properties':
            code = []
            for line in part_content:
                var_name, doc = split_name_doc(line)
                code.append(new_variable(var_name, doc))
            class_content.append(new_region('Static Properties', join(code)))
        elif part == 'Properties':
            code = []
            for line in part_content:
                property_name, doc = split_name_doc(line)
                if property_name == 'this[int]':  # corner case
                    code.append(new_method('__getitem__', ['key'], doc))
                    code.append(new_method('__setitem__', ['key', 'value'], doc))
                else:
                    code.append(new_property(property_name, doc))
            class_content.append(new_region('Properties', join(code)))
        elif part == 'Constructors':
            code = []
            for line in part_content:
                _, doc = split_name_doc(line)
                code.append(new_method('__init__', [], doc))
            class_content.append(join(code))
        elif part == 'Public Methods':
            code = []
            for line in part_content:
                method_name, doc = split_name_doc(line)
                code.append(new_method(method_name, [], doc))
            code.append(new_method('__str__', [], '', 'return self.ToString()'))
            code.append(new_method('__repr__', [], '', 'return self.ToString()'))

            class_content.append(new_region('Public Methods', join(code)))
        elif part == 'Static Methods':
            code = []
            for line in part_content:
                func_name, doc = split_name_doc(line)
                code.append(new_static_method(func_name, doc))
            class_content.append(new_region('Static Methods', join(code)))
        elif part == 'Operators':
            code = []
            for line in part_content:
                op_name, doc = split_name_doc(line)
                op_name = op_name.replace('operator ', '').strip()
                op2method = {
                    '+': '__add__',
                    '-': '__sub__',
                    '*': '__mul__',
                    '/': '__truediv__',
                    '!=': None,  # do nothing, already handled
                    '==': None,  # do nothing, already handled
                    'bool': '__bool__'
                }
                if op_name == '==':  # corner case
                    code.append(new_method('__eq__', ['other'], doc, 'return self.Equals(other)'))
                elif op_name == '!=':  # corner case
                    code.append(new_method('__ne__', ['other'], doc, 'return not self.Equals(other)'))
                else:
                    method_name = op2method[op_name]
                    code.append(new_method(method_name, ['other'], doc))
            class_content.append(new_region('Operators', join(code)))
        elif part == 'Inherited Members':
            pass
        elif part=='Messages': 
            '''same as public methods'''
            code = []
            for line in part_content:
                method_name, doc = split_name_doc(line)
                code.append(new_method(method_name, [], doc))
            class_content.append(new_region('Messages', join(code)))
        else:
            pass
    generated_code.append(
        new_class(class_name, join(class_content), (base_class_name,) if base_class_name else ('',)))
    generated_code = join(generated_code)

    interface_path = '../src/generated_interfaces/' + class_name + '.py'
    path = '../src/' + path + '/' + class_name + '.py'

    with open(interface_path, 'w+') as f:
        f.write(generated_code)



unity_doc()
