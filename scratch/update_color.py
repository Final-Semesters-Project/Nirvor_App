import os
import re

files = [
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\welcome_screen\welcome_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\register_method_screen\register_method_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\register_screen\register_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\login_screen\login_screen.dart"
]

replacement = """        rightWidget: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'English'.tr,
                style: TextStyle(
                  color: Get.locale?.languageCode == 'bn'
                      ? Colors.grey
                      : AppColors.primary,
                  fontWeight: Get.locale?.languageCode == 'bn'
                      ? FontWeight.w400
                      : FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              TextSpan(
                text: '/',
                style: TextStyle(color: Colors.grey, fontSize: 13.sp),
              ),
              TextSpan(
                text: 'বাংলা'.tr,
                style: TextStyle(
                  color: Get.locale?.languageCode == 'bn'
                      ? AppColors.primary
                      : Colors.grey,
                  fontWeight: Get.locale?.languageCode == 'bn'
                      ? FontWeight.w700
                      : FontWeight.w400,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),"""

def replace_in_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # We need to find the `rightWidget: RichText(` up to `),` which might span multiple lines.
    # regex to match `rightWidget: RichText( ... ),`
    # We can use a simpler approach since we know its structure exactly as formatted before.
    pattern = re.compile(r"rightWidget:\s*RichText\([\s\S]*?\]\s*,\s*\)\s*,\s*\),", re.MULTILINE)
    
    new_content = pattern.sub(replacement, content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(new_content)

for file_path in files:
    if os.path.exists(file_path):
        replace_in_file(file_path)
        print(f"Updated {file_path}")
