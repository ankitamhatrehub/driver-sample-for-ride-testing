import re

# Read original driver screens
with open('lib/driver/screens/driver_screens.dart', 'r', encoding='utf-8') as f:
    orig_lines = f.readlines()

# Find the start and end of DriverOnboardingScreen
start_idx = -1
end_idx = -1
for i, line in enumerate(orig_lines):
    if 'class DriverOnboardingScreen extends StatefulWidget {' in line:
        start_idx = i
    if 'class DriverHomeScreen extends StatefulWidget {' in line:
        end_idx = i
        break

# Read new onboarding logic
with open('lib/driver/screens/driver_onboarding_temp.dart', 'r', encoding='utf-8') as f:
    new_onboarding = f.read()

# Replace the block
new_content = ''.join(orig_lines[:start_idx]) + new_onboarding + '\n' + ''.join(orig_lines[end_idx:])

# Write it back
with open('lib/driver/screens/driver_screens.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print('Successfully injected the new onboarding logic into driver_screens.dart')
