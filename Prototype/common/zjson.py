# coding=utf-8
"""
很老的项目
更新历史：
1. 2018年3月3日
2. 2018年8月7日
3. 2020年8月7日

"""
import sys
from collections import namedtuple, defaultdict, OrderedDict
from json import dumps, load as _load, loads as _loads
from re import sub

JsonObject = object  # indicate 标准库 json.load 返回的对象，即标准库支持序列化与反序列化的对象；这里只是提示一下类型，不是严格的
Text = str  # indicate the parsed text
Regex = str  # indicate the regex str

# ---------------------------------------------------
# 选项
# ---------------------------------------------------
KEY_CHECK_STR = True  # 字典key必须是str，大可不必
OBJECT_IN_SHORT = False  # inst作为val时输出类型和id即可，不要打印所有属性


# region serialize


def _make_encodable(obj, decodable=True):
    """
    make class obj serializable to json, please conform to json standard
    commonly, class is encoded with a special dict that contains class mod name, class name and class dict so that it can be decoded then
    set `decodable to False to output as simple dict，这样在debug时易读
    :param obj:
    :param undecodable:
    :return:json_obj, commonly a dict
    """
    # TODO 错误处理，else来报错是不存在的
    # TODO 日后类型等限制可能解除，所以有些地方要再思考一下，比如class obj处
    # TODO class不支持继承，这是非常难做到的，需要了解mro机制
    # 一个简单的想法，class的继承是比较难做的，先不管
    # 添加了set，tuple，但是是硬编码，这是没办法的，builtin没法像那样处理（其实没查）
    if isinstance(obj, (int, float, str, bool)):
        return obj
    elif isinstance(obj, list):
        return [_make_encodable(i, decodable=decodable) for i in obj]
    elif isinstance(obj, tuple):
        if is_namedtuple_instance(obj):
            _ret_cls_name = sub("\(.*\)", "", repr(obj))
            _ret_item = {_make_encodable(key, decodable=decodable): _make_encodable(val, decodable=decodable) for
                         key, val in
                         dict(obj._asdict()).items()}
            return {'__namedtuple_cls_name': _ret_cls_name, '__namedtuple_dict': _ret_item}
        else:
            _ret = [_make_encodable(i, decodable=decodable) for i in obj]
            _ret.insert(0, '__tuple__')  # 不需要元信息
            return _ret
    elif isinstance(obj, set):
        _ret = [_make_encodable(i, decodable=decodable) for i in obj]
        _ret.insert(0, '__set__')
        return _ret
    elif isinstance(obj, frozenset):
        _ret = [_make_encodable(i, decodable=decodable) for i in obj]
        _ret.insert(0, '__frozenset__')
        return _ret
    elif isinstance(obj, dict):
        # 对于inst作为key，可以的
        if KEY_CHECK_STR:
            for key, val in obj.items():
                assert isinstance(key, str)
        return {str(key): _make_encodable(val, decodable=decodable) for key, val in
                obj.items()}
    elif obj is None:
        return None
    else:  # class type; note that isinstanceof(object) is useless since even dict returns true
        if not decodable:  # if decoable is set to false, class info wont be recorded
            if OBJECT_IN_SHORT:
                return str(obj)
            return {_make_encodable(key, decodable=decodable): _make_encodable(val, decodable=decodable) for key, val in
                    obj.__dict__.items()}
        else:
            _ret = {'__class_module__': obj.__class__.__module__, '__class_name__': obj.__class__.__name__,
                    '__class_dict__': {}}
            for key, value in obj.__dict__.items():
                _ret['__class_dict__'][_make_encodable(key, decodable=decodable)] = _make_encodable(value,
                                                                                                    decodable=decodable)
            return _ret


def beautified_json(obj, decodable=True):
    """return beautified json str of obj;
       also used to overwrite obj.__str__ for pretty output eg. def __str__(self):return beau...(self)"""
    return dumps(_make_encodable(obj, decodable=decodable), indent=4, sort_keys=True)


def compact(f):
    """ remove spaces from str output of f, used for test for convenience"""

    def _wrapper(*args, **kwargs):
        return f(*args, **kwargs).replace(' ', '')

    return _wrapper


@compact
def plain_json(obj, decodable=True):
    """return plain/compact json str of obj
       add "@compact" for test"""
    return dumps(_make_encodable(obj, decodable=decodable))


# endregion


# region deserialize


def _decode(json_obj):
    if is_class_dict(json_obj):  # class must be checked before dict, or it will be...
        # if it is a encoded class, we load class (class is object in python) and new it, then recursively build its dict
        cls = load_class(json_obj['__class_module__'], json_obj['__class_name__'])
        # instance = object.__new__(cls)
        instance = cls()
        instance.__dict__ = {_decode(key): _decode(val) for key, val in json_obj['__class_dict__'].items()}
        return instance
    elif is_named_tuple_dict(json_obj):
        global namedtuple_classes
        if namedtuple_classes[json_obj['__namedtuple_cls_name']] is None:
            namedtuple_classes[json_obj['__namedtuple_cls_name']] = namedtuple(json_obj['__namedtuple_cls_name'],
                                                                               json_obj['__namedtuple_dict'].keys())
        cls = namedtuple_classes[json_obj['__namedtuple_cls_name']]
        return cls(**OrderedDict(json_obj['__namedtuple_dict']))
    elif isinstance(json_obj, (int, float, str, bool, unicode)):
        return json_obj
    elif isinstance(json_obj, list):
        _ret = [_decode(i) for i in json_obj]
        if _ret:
            if _ret[0] == '__tuple__':
                return tuple(_ret[1:])
            elif _ret[0] == '__set__':
                return set(_ret[1:])
            elif _ret[0] == '__frozenset__':
                return frozenset(_ret[1:])
        return _ret
    elif json_obj is None:
        return None
    elif isinstance(json_obj, dict):
        return {_decode(key): _decode(val) for key, val in json_obj.items()}


def load(path):
    with open(path, 'r') as f:
        return _decode(_load(f))


def loads(json_text):
    return _decode(_loads(json_text))


namedtuple_classes = defaultdict(lambda: None)  # cls_name => {namedtuple}cls

# endregion

# region json parser
import re


class ZJsonParseError(RuntimeError): pass


class ZJsonValueError(ZJsonParseError): pass


class ZJsonTypeError(ZJsonParseError): pass


def parse(json_text):
    """
    simple json parser
    :param json_text:
    :return:
    """
    Failure = (None, None)  # singleton that indicate parse failure, note failure is not error
    ws = '\s*'
    tokenizer = ws + '(%s)' + ws  # regex to match against (and consume) the start of remainder
    literal_map = {'true': True, 'false': False, 'null': None}
    literal = 'null|true|false'
    number = '-?[0-9]+(\.[0-9]+)?'  # 不是特别严谨，只match -1.1这种
    string = '\"(\\.|.)*\"'  # 不是特别严谨，这里转义处理甚至可能是错的。我不知道regex里的alt是否有序；这里是错的，str内容的贪心不知道怎么处理
    value = '.*?'  # 仅为方便，检查会在下一层递归进行
    array = r'\[((%s\,)*%s)\]' % (value, value)  # 可能只需要[.*?]即可，但是多一些好了。验证格式
    pair = '%s\:%s' % (string, value)
    obj = r'\{((%s,)*%s)\}' % (pair, pair)

    def parse_literal(match_obj):
        return literal_map[match_obj.group(1)]

    def parse_number(match_obj):
        return float(match_obj.group(1))

    def parse_string(match_obj):
        return match_obj.group(1).strip('\"')

    def parse_array(match_obj):
        return [parse_value(i)[0] for i in match_obj.group(2).split(',')]

    def parse_obj(match_obj):
        return {pair[0].strip('\"'): parse_value(pair[1])[0] for pair in
                map(lambda x: x.split(':'), match_obj.group(2).split(','))}

    # 这个写成tuple会更好，因为只需要遍历pair
    grammar = {
        literal: parse_literal,
        number: parse_number,
        string: parse_string,
        array: parse_array,
        obj: parse_obj
    }

    def parse_value(remainder):
        '''return (json_obj, remainder) or Fail '''
        for k, v in grammar.items():
            match_obj = re.match(tokenizer % k, remainder)
            if match_obj:
                return v(match_obj), None  # remainder[match_obj.end():]
        raise ZJsonValueError('invalid json value')

    return parse_value(json_text)[0]


# endregion

def load_class(module, name):
    """ loads the module and returns the class.

    >>> load_class('test.classes','A')
    <class 'test.classes.A'>
    """
    __import__(module)
    mod = sys.modules[module]
    cls = getattr(mod, name)
    return cls


def is_class_dict(obj):
    """ helper class that tests to see if the obj is a flattened object

    >>> is_class_dict({'__class_module__':'__builtin__', '__class_name__':'int'})
    True
    >>> is_class_dict({'key':'value'})
    False
    >>> is_class_dict(25)
    False
    """
    if type(obj) is dict and \
            obj.__contains__('__class_module__') and obj.__contains__('__class_name__'):
        return True
    return False


def is_named_tuple_dict(obj):
    return isinstance(obj, dict) and \
           obj.__contains__('__namedtuple_cls_name') and obj.__contains__('__namedtuple_dict')


def is_namedtuple_instance(x):
    t = type(x)
    b = t.__bases__
    if len(b) != 1 or b[0] != tuple: return False
    f = getattr(t, '_fields', None)
    if not isinstance(f, tuple): return False
    return all(type(n) == str for n in f)


def create_function_dict(*functions):
    return {f.__name__: f for f in functions}
