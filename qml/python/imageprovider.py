#
# PyOtherSide: Asynchronous Python 3 Bindings for Qt 5 and Qt 6
# Copyright (c) 2011, 2013, Thomas Perl <m@thp.io>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

import pyotherside
import math
import zipfile
import rarfile

def render(image_id, requested_size):
#    print('image_id: "{image_id}", size: {requested_size}'.format(**locals()))

    # width and height will be -1 if not set in QML
    if requested_size == (-1, -1):
        requested_size = (300, 300)

    width, height = requested_size

    path = image_id[0:image_id.rfind('+')]
    if ".cbr+" in image_id:
        with rarfile.RarFile(path, mode="r") as archive:
            namelist = archive.namelist()
            namelist.sort()
            namelist2 = [val for val in namelist if not val.endswith("/")]
            bytes = archive.read(namelist2[int(image_id[image_id.rfind('+'):])])
        return bytearray(bytes), (width, height), pyotherside.format_data
    else:
        with zipfile.ZipFile(path, mode="r") as archive:
            namelist = archive.namelist()
            namelist.sort()
            namelist2 = [val for val in namelist if not val.endswith("/")]
            bytes = archive.read(namelist2[int(image_id[image_id.rfind('+'):])])
        return bytearray(bytes), (width, height), pyotherside.format_data
pyotherside.set_image_provider(render)
