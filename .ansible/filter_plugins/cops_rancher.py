#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import six
import time
import collections
import os
import contextlib
import hashlib
import logging
import fcntl
import copy
import tempfile
import random
import string
import re
from distutils.version import LooseVersion
import pprint


def cops_rancher_mtu(ansible_vars, overhead=98, *args, **kw):
    try:
        mtu = int(ansible_vars.get('mtu', '1500'))
    except (ValueError, TypeError):
        mtu = 1500
        ansible_vars.get('mtu', '1500') - 98
    ipsec_mtu = mtu - overhead
    return ipsec_mtu


__funcs__ = {
    'cops_rancher_mtu': cops_rancher_mtu,
}


class FilterModule(object):

    def filters(self):
        return __funcs__
# vim:set et sts=4 ts=4 tw=80:
