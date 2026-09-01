import os
import re

files = [
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\welcome_screen\welcome_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\register_method_screen\register_method_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\register_screen\register_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\login_screen\login_screen.dart"
]

def clean_up_appbar(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # The block starts with `rightOnTap:` and ends after `rightWidget:` definition
    # Because formatting might have slight variations, we'll use a regex that matches rightOnTap up to the end of rightWidget
    pattern = re.compile(
        r"rightOnTap:\s*\(\)\s*\{\s*if\s*\(Get\.locale\?\.languageCode.*?rightWidget:\s*RichText\([\s\S]*?\]\s*,\s*\)\s*,\s*\),",
        re.MULTILINE | re.DOTALL
    )
    
    # Check if we can find it
    if pattern.search(content):
        # We replace it with `showLanguageSwitcher: true,`
        new_content = pattern.sub(r"showLanguageSwitcher: true,", content)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Cleaned up {path}")
    else:
        print(f"Pattern not found in {path}")

for file_path in files:
    if os.path.exists(file_path):
        clean_up_appbar(file_path)

