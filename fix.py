import re

with open('lib/driver/screens/driver_screens.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# Fix java.io.File bug
code = code.replace('java.io.File(_dlImage!.path)', 'File(_dlImage!.path)')

# Add missing imports
imports_to_add = '''import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../customer/screens/customer_screens.dart' show BouncingWidget;
'''

if 'import \\'dart:async\\';' not in code:
    code = code.replace('import \\'package:flutter/material.dart\\';', 'import \\'package:flutter/material.dart\\';\n' + imports_to_add)

with open('lib/driver/screens/driver_screens.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print('Fixed imports and File class issue')
