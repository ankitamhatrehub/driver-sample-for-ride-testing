import re

file_path = 'lib/driver/screens/driver_screens.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Basic Renaming
code = code.replace('CustomerOnboardingScreen', 'DriverOnboardingScreen')
code = code.replace('CustomerDashboardScreen', 'DriverDashboardScreen')
code = code.replace('CustomerApp', 'DriverApp')
code = code.replace('../customer_app.dart', '../driver_app.dart')

# 2. Fix the primary color logic in build() methods
code = re.sub(r'final isPink = _selectedGender == \'Female\';\s*final primaryColor = [^;]+;', 'final primaryColor = const Color(0xFF4F46E5); // Deep Indigo', code)
code = code.replace('final isPink = DriverApp.isPinkTheme.value;\n    final primaryColor = isPink ? const Color(0xFFEC4899) : const Color(0xFF6366F1);', 'final primaryColor = const Color(0xFF4F46E5);')

# 3. Fix the build step content calls
code = code.replace('_buildStepContent(primaryColor, isPink)', '_buildStepContent(primaryColor)')
code = code.replace('Widget _buildStepContent(Color primaryColor, bool isPink)', 'Widget _buildStepContent(Color primaryColor)')

# 4. Remove pink theme toggles in SharedPreferences
code = re.sub(r'await prefs.setBool\(\'is_pink_theme\'.*?\);\s*', '', code)
code = re.sub(r'DriverApp\.isPinkTheme\.value = .*?;\s*', '', code)

# 5. Dashboard Navigation
dashboard_nav = '''
  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
'''
code = re.sub(r'void _navigateToDashboard\(\) \{[\s\S]*?\}', dashboard_nav.strip(), code)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(code)
print('Initial refactor applied successfully.')
