import 'package:flutter/material.dart';

class LegalSection {
  final int number;
  final String titleEn;
  final String titleBn;
  final String contentEn;
  final String contentBn;
  final IconData icon;

  const LegalSection({
    required this.number,
    required this.titleEn,
    required this.titleBn,
    required this.contentEn,
    required this.contentBn,
    required this.icon,
  });

  String title(bool isBn) => isBn ? titleBn : titleEn;
  String content(bool isBn) => isBn ? contentBn : contentEn;
}

class NirbhorLegalData {
  static const String version = '1.2.0';
  static const String lastUpdatedEn = 'January 2026';
  static const String lastUpdatedBn = 'জানুয়ারি ২০২৬';
  static const String supportEmail = 'support@nirbhor.com';
  static const String hotline = '+880 1800-000000';

  // ===================== TERMS AND CONDITIONS =====================
  static const List<LegalSection> termsAndConditions = [
    LegalSection(
      number: 1,
      titleEn: '1. Introduction & Platform Purpose',
      titleBn: '১. ভূমিকা ও প্ল্যাটফর্মের উদ্দেশ্য',
      contentEn:
          'Welcome to Nirbhor ("নির্ভর"). Nirbhor is an on-demand local services platform operating in Bangladesh that connects Service Seekers (clients requiring home, repair, or technical assistance) with skilled independent Service Providers (technicians, electricians, plumbers, home helpers, etc.). By registering, accessing, or using any service through this mobile application, you acknowledge and agree to comply with these Terms and Conditions.',
      contentBn:
          'নির্ভর (Nirbhor)-এ আপনাকে স্বাগতম। নির্ভর হলো বাংলাদেশে পরিচালিত একটি আধুনিক লোকাল সার্ভিস প্ল্যাটফর্ম, যা দক্ষ সেবাদাতা (যেমন: ইলেকট্রিশিয়ান, প্লাম্বার, টেকনিশিয়ান, গৃহস্থালি সহায়ক) এবং সেবাপ্রার্থী গ্রাহকদের মধ্যে বিশ্বস্ত সংযোগ স্থাপন করে। অ্যাপটি ব্যবহারের মাধ্যমে আপনি এই সকল শর্তাবলী ও নির্দেশিকা মেনে চলতে সম্মতি জ্ঞাপন করছেন।',
      icon: Icons.info_outline,
    ),
    LegalSection(
      number: 2,
      titleEn: '2. User Eligibility & Account Registration',
      titleBn: '২. অ্যাকাউন্ট নিবন্ধন ও যোগ্যতা',
      contentEn:
          'Users must be at least 18 years old and hold an active Bangladeshi mobile number to register. You are solely responsible for maintaining the confidentiality of your login credentials. Providers are required to submit genuine identity details (National ID / NID) for verification. Any account found using misleading, false, or impersonated identity will be permanently deactivated.',
      contentBn:
          'প্ল্যাটফর্মে যুক্ত হতে ব্যবহারকারীর বয়স ন্যূনতম ১৮ বছর এবং একটি কার্যকর বাংলাদেশি মোবাইল নম্বর থাকা আবশ্যক। অ্যাকাউন্টের পাসওয়ার্ড ও ওটিপি (OTP)-এর নিরাপত্তা রক্ষা করা একান্তই ব্যবহারকারীর দায়িত্ব। সেবাদাতাদের ক্ষেত্রে সঠিক জাতীয় পরিচয়পত্র (NID) ও তথ্য প্রদান বাধ্যতামূলক। কোনো প্রকার ভুল বা অসত্য তথ্য দিলে অ্যাকাউন্ট স্থায়ীভাবে বাতিল হতে পারে।',
      icon: Icons.account_circle_outlined,
    ),
    LegalSection(
      number: 3,
      titleEn: '3. Booking & Service Fulfillment',
      titleBn: '৩. সেবা বুকিং ও নিয়োগ প্রক্রিয়া',
      contentEn:
          'Service Seekers may browse available providers, check skills and ratings, and initiate service requests. A booking is formally confirmed when both the Seeker and the Provider agree on the schedule and task requirements. Both parties are expected to communicate respectfully, arrive punctually, and execute the agreed tasks with professionalism and care.',
      contentBn:
          'সেবাপ্রার্থী গ্রাহকরা তাদের প্রয়োজনীয়তা অনুযায়ী কাছাকাছি থাকা দক্ষ সেবাদাতাদের প্রোফাইল, কাজের অভিজ্ঞতা ও রেটিং দেখে বুকিং পাঠাতে পারেন। উভয় পক্ষ কাজ ও সময়ের ব্যাপারে একমত হলে বুকিং নিশ্চিত হয়। সেবা প্রদান ও গ্রহণের ক্ষেত্রে পারস্পরিক সম্মান, সময়ানুবর্তিতা এবং সততা বজায় রাখা আবশ্যক।',
      icon: Icons.calendar_today_outlined,
    ),
    LegalSection(
      number: 4,
      titleEn: '4. Service Charges & Direct Payments',
      titleBn: '৪. সার্ভিস চার্জ ও পারিশ্রমিক পরিশোধ',
      contentEn:
          'Service rates vary depending on the nature and complexity of the task, materials needed, and mutual negotiation between the Seeker and the Provider. Payment is made directly by the Seeker to the Provider via cash or mobile banking (bKash/Nagad/Rocket) immediately after the service is completed satisfactorily. Nirbhor does not deduct unauthorized hidden fees.',
      contentBn:
          'কাজের ধরন, প্রয়োজনীয় যন্ত্রাংশ ও পরিধির ওপর নির্ভর করে উভয় পক্ষের আলোচনার মাধ্যমে কাজের পারিশ্রমিক নির্ধারিত হয়। কাজ সফল ও সন্তোষজনকভাবে সম্পন্ন হওয়ার পর গ্রাহক সরাসরি সেবাদাতাকে নগদ বা মোবাইল ব্যাংকিং (বিকাশ/নগদ/রকেট)-এর মাধ্যমে পারিশ্রমিক পরিশোধ করবেন। নির্ভর প্ল্যাটফর্মে কোনো অপ্রকাশিত অতিরিক্ত ফি নেই।',
      icon: Icons.payments_outlined,
    ),
    LegalSection(
      number: 5,
      titleEn: '5. Cancellation & Rescheduling Policy',
      titleBn: '৫. বুকিং বাতিল ও সময় পরিবর্তন',
      contentEn:
          'Either party may cancel an initiated booking before work has started if valid circumstances arise. However, repeated cancellations without acceptable cause, unannounced no-shows, or cancelling after the provider has arrived at the location disrupts the community and may lead to account penalties or temporary service restrictions.',
      contentBn:
          'কাজ শুরুর পূর্বে জরুরি বা যুক্তিসঙ্গত কারণে উভয় পক্ষের যেকোনো পক্ষ বুকিং বাতিল করতে পারেন। তবে কোনো পূর্ব নোটিশ ছাড়া অযৌক্তিকভাবে বারবার বুকিং বাতিল করা, নির্ধারিত সময়ে উপস্থিত না হওয়া অথবা সেবাদাতা ঠিকানায় পৌঁছানোর পর হুট করে কাজ বাতিল করলে রেটিং কমে যেতে পারে বা অ্যাকাউন্ট সাময়িকভাবে স্থগিত হতে পারে।',
      icon: Icons.cancel_outlined,
    ),
    LegalSection(
      number: 6,
      titleEn: '6. Provider Verification & Badges',
      titleBn: '৬. প্রোভাইডার ভেরিফিকেশন ও নিরাপত্তা',
      contentEn:
          'Nirbhor verifies provider identities using government-issued NID and profile assessments to award "Verified" or "Trusted" badges. While these measures significantly increase safety and trustworthiness, users are strongly advised to exercise standard precautions and vigilance when welcoming service professionals into residential premises.',
      contentBn:
          'নির্ভর প্ল্যাটফর্মে সেবাদাতাদের জাতীয় পরিচয়পত্র (NID) ও পূর্ব কাজের রেকর্ড যাচাই-বাছাই করে ভেরিফিকেশন ব্যাজ দেওয়া হয়। এটি নিরাপত্তা বহুগুণ বাড়িয়ে তোলে। তা সত্ত্বেও নিজস্ব বাসাবাড়িতে সেবা গ্রহণের সময় সাধারণ সতর্কতা ও সচেতনতা বজায় রাখার জন্য উভয় পক্ষকে অনুরোধ করা হচ্ছে।',
      icon: Icons.verified_user_outlined,
    ),
    LegalSection(
      number: 7,
      titleEn: '7. Ratings, Reviews & AI Summaries',
      titleBn: '৭. রেটিং, রিভিউ ও এআই সামারি',
      contentEn:
          'Once a service is marked complete, Seekers can submit genuine star ratings and written reviews (with an anonymous submission option). Reviews must be truthful, polite, and free from slanderous or vulgar language. Nirbhor uses AI review summarization to help users easily grasp past performance trends.',
      contentBn:
          'কোনো কাজ সমাপ্ত হলে সেবাপ্রার্থী তার অভিজ্ঞতা অনুযায়ী সত্য ও বস্তুনিষ্ঠ রেটিং ও রিভিউ দিতে পারবেন (প্রয়োজনে বেনামেও রিভিউ দেওয়া সম্ভব)। কোনো অবমাননাকর বা বিভ্রান্তিকর মন্তব্য গ্রহণযোগ্য নয়। এআই সামারির মাধ্যমে পূর্ববর্তী কাজের সারসংক্ষেপ গ্রাহকদের সঠিক সেবাদাতা বেছে নিতে সহায়তা করে।',
      icon: Icons.star_border_outlined,
    ),
    LegalSection(
      number: 8,
      titleEn: '8. Safety, Code of Conduct & Prohibited Acts',
      titleBn: '৮. নিরাপত্তা ও আচরণবিধি',
      contentEn:
          'Harassment, verbal abuse, theft, property damage, safety endangerment, illegal trade, and deceptive actions are strictly forbidden. You must never misuse phone numbers or private information acquired via Nirbhor for unsolicited communications or unauthorized solicitation outside the app.',
      contentBn:
          'কোনো প্রকার হয়রানি, অশালীন আচরণ, চুরি, সম্পত্তির ক্ষতিসাধন, বিপজ্জনক কাজ বা প্রতারণামূলক কার্যকলাপ সম্পূর্ণ নিষিদ্ধ। নির্ভর প্ল্যাটফর্ম থেকে প্রাপ্ত মোবাইল নম্বর বা ব্যক্তিগত তথ্য কোনো অযাচিত কাজে বা বাইরে অসৎ উদ্দেশ্যে ব্যবহার করা যাবে না।',
      icon: Icons.gavel_outlined,
    ),
    LegalSection(
      number: 9,
      titleEn: '9. Disclaimers & Limitation of Liability',
      titleBn: '৯. দায়বদ্ধতার সীমাবদ্ধতা',
      contentEn:
          'Nirbhor serves as a technology platform connecting independent service participants. Nirbhor is not an employer or principal of registered service providers. While we take every reasonable measure to protect user interests and arbitrate complaints, Nirbhor is not liable for indirect damages, disputes between parties, or independent workmanship beyond our platform boundaries.',
      contentBn:
          'নির্ভর মূলত একটি ডিজিটাল প্ল্যাটফর্ম যা স্বাধীন কারিগর ও গ্রাহকদের মধ্যে সেতুবন্ধন তৈরি করে। নির্ভর সেবাদাতাদের প্রত্যক্ষ নিয়োগকর্তা নয়। কোনো সমস্যা বা অভিযোগের ক্ষেত্রে নির্ভর আন্তরিকভাবে মধ্যস্থতা করে থাকে, তবে উভয় পক্ষের ব্যক্তিগত বিরোধ বা অনভিপ্রেত ক্ষতির জন্য প্ল্যাটফর্ম আইনিভাবে একক দায়ী থাকবে না।',
      icon: Icons.shield_outlined,
    ),
    LegalSection(
      number: 10,
      titleEn: '10. Modifications & Support Contact',
      titleBn: '১০. শর্তাবলীর পরিবর্তন ও সহায়তা',
      contentEn:
          'We reserve the right to revise these Terms as our platform evolves. Continued use of Nirbhor indicates agreement with any updated terms. For queries, grievances, or support, please reach us through the in-app help desk or email us at support@nirbhor.com.',
      contentBn:
          'প্ল্যাটফর্মের উন্নয়ন ও সেবার মান বৃদ্ধির স্বার্থে নির্ভর কর্তৃপক্ষ যেকোনো সময় শর্তাবলী পরিবর্তন বা হালনাগাদ করার অধিকার সংরক্ষণ করে। যেকোনো প্রশ্ন, মতামত বা সহায়তার জন্য অ্যাপের সহায়তা ডেস্ক অথবা support@nirbhor.com-এ যোগাযোগ করতে পারেন।',
      icon: Icons.contact_support_outlined,
    ),
  ];

  // ===================== PRIVACY POLICY =====================
  static const List<LegalSection> privacyPolicy = [
    LegalSection(
      number: 1,
      titleEn: '1. Introduction & Our Privacy Pledge',
      titleBn: '১. ভূমিকা ও তথ্য সুরক্ষার অঙ্গীকার',
      contentEn:
          'At Nirbhor ("নির্ভর"), we recognize the importance of your personal privacy and the trust you place in us. This Privacy Policy outlines what information we collect from Service Seekers and Providers, how it is utilized, and the safeguards applied to keep your personal data secure.',
      contentBn:
          'নির্ভর (Nirbhor)-এ আপনার ব্যক্তিগত তথ্যের গোপনীয়তা ও সুরক্ষা আমাদের কাছে অত্যন্ত মূল্যবান। এই নীতিমালায় আমরা স্পষ্ট করেছি যে সেবাগ্রহীতা ও সেবাদাতাদের কাছ থেকে কী ধরনের তথ্য সংগ্রহ করা হয়, কীভাবে তা ব্যবহৃত হয় এবং কীভাবে সর্বোচ্চ নিরাপত্তা নিশ্চিত করা হয়।',
      icon: Icons.lock_outline,
    ),
    LegalSection(
      number: 2,
      titleEn: '2. Information We Collect',
      titleBn: '২. আমরা যে তথ্য সংগ্রহ করি',
      contentEn:
          '• Personal Identification: Full name, Bangladeshi mobile phone number, and profile picture.\n• Provider Identity Verification: National Identification Number (NID/Smart card), skill qualifications, trade certificates, and service radius.\n• Geolocation Data: Precise or approximate GPS coordinates collected when searching for nearby services or setting provider service coverage.\n• Transaction & Service Records: Booking schedules, service status, communication timestamps, and customer reviews.',
      contentBn:
          '• ব্যক্তিগত পরিচিতি: পুরো নাম, বাংলাদেশি মোবাইল নম্বর এবং প্রোফাইল ছবি।\n• সেবাদাতার ভেরিফিকেশন তথ্য: জাতীয় পরিচয়পত্র (NID), কাজের দক্ষতা, অভিজ্ঞতা ও সার্ভিস রেডিয়াস।\n• ভৌগোলিক অবস্থান (লোকেশন): কাছাকাছি সেবাদাতা খুঁজে দেওয়া ও সার্ভিস এলাকা নির্ধারণের জন্য জিপিএস লোকেশন ডেটা।\n• সেবার রেকর্ড ও বুকিং হিস্ট্রি: বুকিংয়ের সময়সূচি, কাজের স্ট্যাটাস, রেটিং এবং কাস্টমার রিভিউ।',
      icon: Icons.folder_shared_outlined,
    ),
    LegalSection(
      number: 3,
      titleEn: '3. How We Use Collected Information',
      titleBn: '৩. তথ্যের ব্যবহার পদ্ধতি',
      contentEn:
          'We use collected data strictly for platform operation:\n• Matching Seekers with nearby, qualified Providers efficiently.\n• Authenticating users via OTP and preventing fraud or impersonation.\n• Sending real-time service notifications, booking alerts, and updates.\n• Generating AI-assisted performance summaries and improving system algorithms.',
      contentBn:
          'সংগৃহীত তথ্য শুধুমাত্র প্ল্যাটফর্মের কার্যক্রম ও সেবার মান বৃদ্ধির জন্য ব্যবহৃত হয়:\n• সেবাপ্রার্থীর সবচেয়ে কাছাকাছি উপযুক্ত কারিগরকে দ্রুত খুঁজে দেওয়া।\n• ওটিপি (OTP) ভেরিফিকেশনের মাধ্যমে ভুয়া অ্যাকাউন্ট ও প্রতারণা প্রতিরোধ করা।\n• বুকিং সংক্রান্ত আপডেট, এসএমএস ও রিয়েল-টাইম নোটিফিকেশন প্রদান করা।\n• কৃত্রিম বুদ্ধিমত্তা (AI) ব্যবহার করে রিভিউ সারসংক্ষেপ তৈরি ও সামগ্রিক নিরাপত্তা বৃদ্ধি।',
      icon: Icons.data_usage_outlined,
    ),
    LegalSection(
      number: 4,
      titleEn: '4. Privacy of Phone Numbers & Contacts',
      titleBn: '৪. ফোন নম্বর ও যোগাযোগের গোপনীয়তা',
      contentEn:
          'Your mobile phone number is protected. It is only disclosed to the specific counterparty once a booking request is actively initiated or accepted for direct service coordination. Public profiles in general search do not expose personal direct contact details.',
      contentBn:
          'আপনার ফোন নম্বর সম্পূর্ণ সুরক্ষিত রাখা হয়। শুধুমাত্র কোনো বুকিং আনুষ্ঠানিকভাবে শুরু বা নিশ্চিত হলে যোগাযোগের স্বার্থে সংশ্লিষ্ট সেবাদাতা বা সেবাপ্রার্থী পরস্পরের নম্বর দেখতে পান। পাবলিক সার্চ তালিকায় সাধারণত সরাসরি যোগাযোগের নম্বর প্রদর্শিত হয় না।',
      icon: Icons.phone_android_outlined,
    ),
    LegalSection(
      number: 5,
      titleEn: '5. Location Data Transparency',
      titleBn: '৫. লোকেশন তথ্যের স্বচ্ছ ব্যবহার',
      contentEn:
          'Location permissions are requested to facilitate proximity-based provider discovery and route mapping. We do not track or store continuous background location when the app is inactive unless required for an active ongoing urgent dispatch.',
      contentBn:
          'শুধুমাত্র সেবা এলাকার দূরত্ব নির্ণয় এবং নিকটস্থ কারিগর খুঁজে পাওয়ার জন্য লোকেশন অনুমতি নেওয়া হয়। অ্যাপটি বন্ধ থাকা অবস্থায় অযথা ব্যাকগ্রাউন্ডে আপনার অবস্থান ট্র্যাক করা হয় না।',
      icon: Icons.location_on_outlined,
    ),
    LegalSection(
      number: 6,
      titleEn: '6. Information Sharing & Third Parties',
      titleBn: '৬. তথ্য বিনিময় ও তৃতীয় পক্ষ',
      contentEn:
          'Nirbhor NEVER sells, rents, or trades your personal information to third-party marketing agencies. Data is only shared with verified backend infrastructure providers necessary to operate the application (such as cloud hosting and transactional SMS gateways) under strict confidentiality agreements.',
      contentBn:
          'নির্ভর কখনোই আপনার ব্যক্তিগত তথ্য কোনো বাণিজ্যিক বিজ্ঞাপনী সংস্থার কাছে বিক্রি বা ভাড়া দেয় না। শুধুমাত্র অ্যাপ পরিচালনার সুবিধার্থে বিশ্বস্ত সার্ভার ও এসএমএস গেটওয়ের মতো প্রয়োজনীয় ক্লাউড সার্ভিস প্রদানকারীদের সাথে গোপনীয়তা চুক্তি সাপেক্ষে প্রযুক্তিগত সংযোগ রাখা হয়।',
      icon: Icons.share_outlined,
    ),
    LegalSection(
      number: 7,
      titleEn: '7. Data Security & Protection',
      titleBn: '৭. ডেটা নিরাপত্তা ও সুরক্ষা ব্যবস্থা',
      contentEn:
          'All network traffic between your device and our servers is secured with industry-standard SSL/TLS encryption. Passwords and sensitive authentication tokens are salted and hashed. We implement proactive server protections against unauthorized access.',
      contentBn:
          'আপনার মোবাইল ও আমাদের সার্ভারের মধ্যকার সকল তথ্য আদান-প্রদান আধুনিক SSL/TLS এনক্রিপশন দ্বারা সুরক্ষিত। পাসওয়ার্ড ও গোপন টোকেন হ্যাশ আকারে ডাটাবেসে অত্যন্ত সতর্কতার সাথে সংরক্ষিত থাকে যাতে অননুমোদিত অ্যাক্সেস রোধ করা যায়।',
      icon: Icons.security_outlined,
    ),
    LegalSection(
      number: 8,
      titleEn: '8. Your Rights & Data Retention',
      titleBn: '৮. আপনার অধিকার ও ডেটা সংরক্ষণ',
      contentEn:
          'You retain full rights to access, update, or edit your profile information at any time from the app settings. You can request complete deactivation of your account and erasure of associated personal records by contacting customer support.',
      contentBn:
          'আপনি যেকোনো সময় আপনার প্রোফাইল তথ্য দেখতে ও আপডেট করতে পারবেন। এছাড়াও আপনি চাইলে কাস্টমার কেয়ারে যোগাযোগ করে আপনার অ্যাকাউন্ট স্থায়ীভাবে মুছে ফেলার এবং ব্যক্তিগত ডেটা রিমুভ করার অনুরোধ জানাতে পারেন।',
      icon: Icons.manage_accounts_outlined,
    ),
    LegalSection(
      number: 9,
      titleEn: '9. Updates to Privacy Policy & Inquiries',
      titleBn: '৯. নীতিমালার পরিবর্তন ও যোগাযোগ',
      contentEn:
          'We may update this Privacy Policy periodically to reflect technological or regulatory changes. Material changes will be communicated via in-app alerts. For inquiries concerning your privacy, email privacy@nirbhor.com.',
      contentBn:
          'প্রযুক্তিগত বা আইনগত প্রয়োজনে সময়ে সময়ে এই গোপনীয়তা নীতি হালনাগাদ করা হতে পারে। যেকোনো বড় পরিবর্তন অ্যাপের মাধ্যমে জানানো হবে। গোপনীয়তা সংক্রান্ত যেকোনো প্রশ্নে যোগাযোগ করুন: privacy@nirbhor.com।',
      icon: Icons.mark_email_read_outlined,
    ),
  ];
}

