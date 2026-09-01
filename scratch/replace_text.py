import os
import re

files = [
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\welcome_screen\welcome_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\register_method_screen\register_method_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\register_screen\register_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\login_screen\login_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\password_login_screen\password_login_screen.dart",
    r"C:\Users\Eusouf\Development\projects\FinalYear_Project\Nirbhor\lib\view\screens\auth_screen\otp_verify_screen\otp_verify_screen.dart"
]

def replace_in_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Remove _isEnglish declaration
    content = re.sub(r'\s*final\s+RxBool\s+_isEnglish\s*=\s*true\.obs;\s*//[^\n]*\n|\s*final\s+RxBool\s+_isEnglish\s*=\s*true\.obs;\s*\n', '\n', content)
    
    # 2. Remove Obx(() => Scaffold( ... ))
    # Replace `return Obx(() => Scaffold(` with `return Scaffold(`
    content = content.replace("return Obx(() => Scaffold(", "return Scaffold(")
    # The last `));` needs to be replaced with `);`
    # We can use regex to find the matching `));` at the end of the build method.
    content = re.sub(r'\)\);\s*}\s*Widget\s+_build', r');\n  }\n\n  Widget _build', content)
    content = re.sub(r'\)\);\s*}', r');\n}', content)

    # 3. Handle rightOnTap
    # `rightOnTap: () => _isEnglish.toggle(),`
    locale_toggle = """rightOnTap: () {
          if (Get.locale?.languageCode == 'en') {
            Get.updateLocale(const Locale('bn'));
          } else {
            Get.updateLocale(const Locale('en'));
          }
        },"""
    content = re.sub(r'rightOnTap:\s*\(\)\s*=>\s*_isEnglish\.toggle\(\),', locale_toggle, content)

    # 4. Handle rightWidget in Appbar
    # This might have `_isEnglish.value ? 'English' : 'বাংলা'` and similar styling.
    # We'll just replace `_isEnglish.value ? 'A' : 'B'` with `'A'.tr`.
    # And `_isEnglish.value ? A : B`
    content = re.sub(r"_isEnglish\.value\s*\?\s*'English'\s*:\s*'[^']+'", "'English'.tr", content)
    content = re.sub(r"_isEnglish\.value\s*\?\s*'[^']+'\s*:\s*'English'", "'বাংলা'.tr", content)
    
    # 5. Handle strings with ternary: `_isEnglish.value ? 'X' : 'Y'` -> `'X'.tr`
    # We'll regex capture the first string.
    content = re.sub(r"_isEnglish\.value\s*\?\s*'([^']+)'\s*:\s*'[^']+'", r"'\1'.tr", content)

    # 6. Add .tr to all known static texts.
    static_texts = [
        "Select how you want to use KajerLok",
        "Hire skilled workers near you",
        "Find work near you",
        "Verified Profiles",
        "Free to Join",
        "Join our trusted community of service providers and seekers. Select your preferred registration method to get started.",
        "1XXX XXXXXX",
        "BD +880",
        "********",
        "Already have an account? ",
        "Verified Trust Ecosystem",
        "By continuing, you agree to our Terms of Service & Privacy Policy",
        "Access your verified community workspace",
        "Google login only available if you linked your Gmail after registration.",
        "Don't have an account?  ",
        "Register Now",
        "Please enter your password to login",
        "Enter your password",
        "Forgot Password?",
        "We sent a code to +880 XXXXX",
        "Didn't receive the code? ",
        "Resend OTP (30s)",
        "This verification helps us keep the KajerLok community safe and reliable for everyone."
    ]

    for txt in static_texts:
        # replace `'txt'` with `'txt'.tr` only if not already `.tr`
        content = re.sub(rf"'{re.escape(txt)}'(?!\.tr)", f"'{txt}'.tr", content)

    # For titles/hints in widgets that we missed, let's catch standard text fields:
    # like title: 'Phone Number'
    # hintText: 'Enter your full name'
    # text: 'OR'
    # text: 'OTP'
    # text: 'Verify OTP'
    # etc.
    simple_texts = [
        "Phone Number", "Enter your full name", "Full Name", "Password", "Confirm Password",
        "Continue", "Log In", "Login", "OTP", "OR", "Continue with Google",
        "Enter Password", "Verify OTP", "Verify", "Verified Trust"
    ]
    for txt in simple_texts:
        content = re.sub(rf"'{re.escape(txt)}'(?!\.tr)", f"'{txt}'.tr", content)
        content = re.sub(rf'"{re.escape(txt)}"(?!\.tr)', f"'{txt}'.tr", content)

    # Clean up rightWidget styling which might still use `_isEnglish.value`
    content = re.sub(r"_isEnglish\.value\s*\?\s*(AppColors\.primary)\s*:\s*(Colors\.grey)", r"\1", content)
    content = re.sub(r"_isEnglish\.value\s*\?\s*(Colors\.grey)\s*:\s*(AppColors\.primary)", r"\2", content)
    content = re.sub(r"_isEnglish\.value\s*\?\s*(FontWeight\.w700)\s*:\s*(FontWeight\.w400)", r"\1", content)
    content = re.sub(r"_isEnglish\.value\s*\?\s*(FontWeight\.w400)\s*:\s*(FontWeight\.w700)", r"\2", content)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

for file_path in files:
    try:
        replace_in_file(file_path)
        print(f"Updated {file_path}")
    except Exception as e:
        print(f"Failed {file_path}: {e}")

