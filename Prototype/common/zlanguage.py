# coding=utf-8
# zlanguage.py
# created on 2020/9/27
# author @zoloypzuo
# usage: zlanguage

import gettext
import zconfig

zh = gettext.translation('zh_CN', zconfig.TheConfig.Common.engineDir, ['locale'])
zh.install()
_ = zh.gettext

print _('hello world')
