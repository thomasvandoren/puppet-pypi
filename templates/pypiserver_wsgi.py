#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Pypi Server WSGI App."""

from   __future__ import print_function, unicode_literals

import pypiserver
application = pypiserver.app('<%= pypi_root %>/packages', redirect_to_fallback=False, password_file='<%= pypi_root %>/.htaccess')
