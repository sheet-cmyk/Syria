#!/usr/bin/env python3
"""
رفع 100 إعلان وهمي عراقي احترافي إلى Firestore
يشغّل هذا السكريبت على جهازك بعد تثبيت:
  pip install firebase-admin
وتوفير ملف serviceAccountKey.json من Firebase Console
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta
import random
import os
import sys

# ─── إعداد Firebase ───────────────────────────────────────────────
KEY_FILE = "serviceAccountKey.json"
if not os.path.exists(KEY_FILE):
    print(f"❌  الملف '{KEY_FILE}' غير موجود!")
    print("📌  حمّله من: Firebase Console → Project Settings → Service Accounts → Generate new private key")
    sys.exit(1)

cred = credentials.Certificate(KEY_FILE)
firebase_admin.initialize_app(cred)
db = firestore.client()

# ─── بيانات الإعلانات ─────────────────────────────────────────────

CITIES = [
    "بغداد", "الموصل", "البصرة", "أربيل", "كركوك",
    "النجف", "كربلاء", "بابل", "الأنبار", "صلاح الدين",
    "ديالى", "ميسان", "ذي قار", "المثنى", "القادسية",
    "واسط", "سليمانية", "دهوك"
]

# أسماء ذكور وإناث عراقية
MALE_NAMES = [
    "أحمد محمد", "علي حسن", "محمد علي", "حسين عبدالله", "عمر خالد",
    "يوسف إبراهيم", "زياد ناصر", "عمار رزاق", "سامر طارق", "فراس جاسم",
    "مصطفى حمد", "باسم عادل", "لؤي صالح", "وليد كريم", "حيدر عليوي",
    "قاسم جبار", "ليث عامر", "رعد فاضل", "صادق حمزة", "نزار توفيق",
    "هيثم ثامر", "سعد نوري", "بلال منير", "أنس شاكر", "جلال محمود"
]

FEMALE_NAMES = [
    "فاطمة علي", "زينب حسن", "مريم خالد", "نور محمد", "رهف أحمد",
    "سارة عبدالله", "هدى كريم", "رنا صالح", "لقاء عمر", "دنيا جاسم",
    "حنان طارق", "إيمان رزاق", "شيماء ناصر", "بيان إبراهيم", "سجى عادل",
    "ياسمين توفيق", "وفاء حمد", "أسيل منير", "تبارك شاكر", "غزل فاضل",
    "أميرة حمزة", "ملاك نوري", "شروق كامل", "إنعام جبار", "دعاء عليوي"
]

# صور حسابات واقعية من Unsplash (أشخاص عرب/شرق أوسطيون)
MALE_AVATARS = [
    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1568602471122-7832951cc4c5?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1548142813-c348350df52b?w=150&h=150&fit=crop&crop=face",
]

FEMALE_AVATARS = [
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1542206395-9feb3edaa68d?w=150&h=150&fit=crop&crop=face",
    "https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=150&h=150&fit=crop&crop=face",
]

# ─── بيانات الإعلانات المفصلة ────────────────────────────────────

ADS_DATA = [
    # ─── عقارات (18 إعلان) ───
    {
        "title": "بيت للبيع - الكرادة الداخلية",
        "category": "عقارات",
        "subCategory": "بيوت للبيع",
        "price": "185000",
        "currency": "USD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "بيت طابقين طابو صرف، مساحة 200 متر، 4 غرف نوم، صالتين، مطبخ راقي، حوش واسع. موقع ممتاز قريب من الخدمات. السعر قابل للتفاوض للجادين.",
        "images": ["https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=600&h=400&fit=crop"],
    },
    {
        "title": "شقة للإيجار - زيونة",
        "category": "عقارات",
        "subCategory": "شقق للإيجار",
        "price": "350000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "ممتاز",
        "description": "شقة 3 غرف نوم + صالة كبيرة + مطبخ مودرن + حمامين. دور ثالث مع مصعد. حي زيونة قرب المدارس والأسواق. الإيجار شهري.",
        "images": ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&h=400&fit=crop"],
    },
    {
        "title": "أرض سكنية للبيع - الجادرية",
        "category": "عقارات",
        "subCategory": "أراضي",
        "price": "95000",
        "currency": "USD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "أرض سكنية 300 متر، طابو صرف، على شارع 12 متر، قرب جامعة بغداد. مناسبة لبناء بيت أو عمارة.",
        "images": ["https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=600&h=400&fit=crop"],
    },
    {
        "title": "بيت للبيع - حي النور الموصل",
        "category": "عقارات",
        "subCategory": "بيوت للبيع",
        "price": "55000",
        "currency": "USD",
        "city": "الموصل",
        "condition": "جيد",
        "description": "بيت طابق واحد مع سطح، 3 غرف + صالة + مطبخ + حمام. حوش صغير. منطقة هادية وآمنة. قريب من المدرسة والجامع.",
        "images": ["https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=600&h=400&fit=crop"],
    },
    {
        "title": "محل تجاري للإيجار - شارع الميدان",
        "category": "عقارات",
        "subCategory": "محلات للإيجار",
        "price": "500000",
        "currency": "IQD",
        "city": "الموصل",
        "condition": "جيد",
        "description": "محل 25 متر على شارع تجاري رئيسي. واجهة زجاجية. مناسب لكافة الأنشطة التجارية. الإيجار شهري شامل الماء والكهرباء.",
        "images": ["https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&h=400&fit=crop"],
    },
    {
        "title": "فيلا للبيع - العشار البصرة",
        "category": "عقارات",
        "subCategory": "بيوت للبيع",
        "price": "220000",
        "currency": "USD",
        "city": "البصرة",
        "condition": "ممتاز",
        "description": "فيلا 3 طوابق، 6 غرف نوم، 3 حمامات، صالة استقبال فاخرة، مطبخ مودرن، جراج سيارتين، حديقة خاصة. بناء 2020.",
        "images": ["https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=600&h=400&fit=crop"],
    },
    {
        "title": "شقة للبيع - أربيل المدينة",
        "category": "عقارات",
        "subCategory": "شقق للبيع",
        "price": "75000",
        "currency": "USD",
        "city": "أربيل",
        "condition": "ممتاز",
        "description": "شقة 130 متر في مجمع سكني راقي، 3 غرف + صالة مفتوحة + مطبخ أمريكي. دور 5 مع مصعد وحراسة 24 ساعة.",
        "images": ["https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=600&h=400&fit=crop"],
    },
    {
        "title": "عمارة للبيع - كركوك المركز",
        "category": "عقارات",
        "subCategory": "عمارات للبيع",
        "price": "280000",
        "currency": "USD",
        "city": "كركوك",
        "condition": "جيد",
        "description": "عمارة 4 طوابق، كل طابق شقتين، 8 شقق بالمجموع. مؤجرة بالكامل. دخل شهري ثابت. طابو صرف.",
        "images": ["https://images.unsplash.com/photo-1486325212027-8081e485255e?w=600&h=400&fit=crop"],
    },

    # ─── سيارات (18 إعلان) ───
    {
        "title": "كيا سبورتاج 2022 - فل أوبشن",
        "category": "سيارات",
        "subCategory": "سيارات للبيع",
        "price": "26500",
        "currency": "USD",
        "city": "بغداد",
        "condition": "ممتاز",
        "description": "كيا سبورتاج موديل 2022، لون رمادي، فل كامل، كاميرا 360، مقاعد جلد، شاشة 10 إنش. ماشية 35 ألف كم فقط. وكالة نظيفة بدون حوادث.",
        "images": ["https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=600&h=400&fit=crop"],
    },
    {
        "title": "تويوتا كامري 2020",
        "category": "سيارات",
        "subCategory": "سيارات للبيع",
        "price": "18500",
        "currency": "USD",
        "city": "البصرة",
        "condition": "جيد",
        "description": "كامري 2020 SE، لون أبيض لؤلؤي. ماشية 62 ألف كم. تايمينج مغير، فحص حكومي سالم. السعر نهائي.",
        "images": ["https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=600&h=400&fit=crop"],
    },
    {
        "title": "هيونداي توسان 2023",
        "category": "سيارات",
        "subCategory": "سيارات للبيع",
        "price": "24000",
        "currency": "USD",
        "city": "الموصل",
        "condition": "ممتاز",
        "description": "توسان 2023 N-Line، لون أزرق. ماشية 18 ألف فقط. فل أوبشن، نظام تدفئة مقاعد، بانوراما، هيد لايت LED.",
        "images": ["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=600&h=400&fit=crop"],
    },
    {
        "title": "نيسان باترول 2019",
        "category": "سيارات",
        "subCategory": "سيارات للبيع",
        "price": "35000",
        "currency": "USD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "باترول V6، لون أسود، 7 راكب. تجهيزات فاخرة. ماشية 85 ألف. مسجل الكاشف. بدون حوادث.",
        "images": ["https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=600&h=400&fit=crop"],
    },
    {
        "title": "هوندا أكورد 2018",
        "category": "سيارات",
        "subCategory": "سيارات للبيع",
        "price": "12800",
        "currency": "USD",
        "city": "أربيل",
        "condition": "جيد",
        "description": "أكورد 2018 Sport، لون أحمر. ماشية 72 ألف. صيانة منتظمة، فل أوبشن. فحص حديث.",
        "images": ["https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=600&h=400&fit=crop"],
    },
    {
        "title": "مرسيدس C200 2021",
        "category": "سيارات",
        "subCategory": "سيارات للبيع",
        "price": "45000",
        "currency": "USD",
        "city": "بغداد",
        "condition": "ممتاز",
        "description": "مرسيدس C200 2021، لون أبيض، مقاعد عجين، شاشة كبيرة، هيد أب ديسبلاي. ماشية 28 ألف. لا تشوف عيب.",
        "images": ["https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=600&h=400&fit=crop"],
    },
    {
        "title": "دايهاتسو شاريد 2017 - اقتصادية",
        "category": "سيارات",
        "subCategory": "سيارات للبيع",
        "price": "6500",
        "currency": "USD",
        "city": "كربلاء",
        "condition": "جيد",
        "description": "شاريد 2017، لون فضي، اقتصادية بالبنزين. ماشية 95 ألف. مناسبة للمشاوير اليومية. فحص جيد.",
        "images": ["https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=600&h=400&fit=crop"],
    },
    {
        "title": "تويوتا برادو 2022 GXR",
        "category": "سيارات",
        "subCategory": "سيارات للبيع",
        "price": "62000",
        "currency": "USD",
        "city": "البصرة",
        "condition": "ممتاز",
        "description": "برادو GXR 2022، لون أبيض، فل كامل، كاميرا 360، مقاعد عجين فاخر. ماشية 22 ألف. وكالة نظيفة.",
        "images": ["https://images.unsplash.com/photo-1568844293986-8d0400bd4745?w=600&h=400&fit=crop"],
    },

    # ─── إلكترونيات وهواتف (18 إعلان) ───
    {
        "title": "آيفون 15 برو ماكس 256 جيجا",
        "category": "إلكترونيات",
        "subCategory": "هواتف ذكية",
        "price": "1250000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "ممتاز",
        "description": "آيفون 15 برو ماكس 256 جيجا، لون تيتانيوم الطبيعي. مفتوح مع جميع الشبكات. باترية 95%. مع صندوقه الأصلي وكل ملحقاته.",
        "images": ["https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=600&h=400&fit=crop"],
    },
    {
        "title": "سامسونج S24 Ultra 512G",
        "category": "إلكترونيات",
        "subCategory": "هواتف ذكية",
        "price": "980000",
        "currency": "IQD",
        "city": "الموصل",
        "condition": "ممتاز",
        "description": "سامسونج S24 Ultra، لون تيتانيوم أسود. 512 جيجا، RAM 12. مع القلم S-Pen. باترية ممتازة. لا فيه أي خربطة.",
        "images": ["https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600&h=400&fit=crop"],
    },
    {
        "title": "لابتوب HP Pavilion Gaming",
        "category": "إلكترونيات",
        "subCategory": "لابتوبات",
        "price": "750000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "HP Pavilion Gaming، Core i7 جيل 12، RTX 3060، 16 RAM، 512 SSD. شاشة 15.6 FHD 144Hz. مستخدم سنة واحدة فقط.",
        "images": ["https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&h=400&fit=crop"],
    },
    {
        "title": "تلفزيون سامسونج 65 بوصة QLED",
        "category": "إلكترونيات",
        "subCategory": "تلفزيونات",
        "price": "850000",
        "currency": "IQD",
        "city": "البصرة",
        "condition": "ممتاز",
        "description": "سامسونج QLED 65 بوصة موديل 2023. دقة 4K، HDR10+، Smart TV. اشتريته قبل 3 أشهر. معه جهاز التحكم وضمان.",
        "images": ["https://images.unsplash.com/photo-1593359677879-a4bb92f829e1?w=600&h=400&fit=crop"],
    },
    {
        "title": "آيباد برو 11 إنش M2",
        "category": "إلكترونيات",
        "subCategory": "أجهزة لوحية",
        "price": "680000",
        "currency": "IQD",
        "city": "أربيل",
        "condition": "ممتاز",
        "description": "آيباد برو M2 11 إنش، 256 جيجا، WiFi+Cellular. مع Apple Pencil الجيل الثاني والكيبورد السحري. حالة ممتازة.",
        "images": ["https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=600&h=400&fit=crop"],
    },
    {
        "title": "بلايستيشن 5 مع 3 ألعاب",
        "category": "إلكترونيات",
        "subCategory": "ألعاب",
        "price": "620000",
        "currency": "IQD",
        "city": "كركوك",
        "condition": "جيد",
        "description": "PS5 ديسك فيرجن + 3 ألعاب (FIFA 24, GTA5, God of War). جهاز شغال مو معدل. باعه لأني سافر.",
        "images": ["https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=600&h=400&fit=crop"],
    },
    {
        "title": "ساعة Apple Watch Series 9",
        "category": "إلكترونيات",
        "subCategory": "ساعات ذكية",
        "price": "420000",
        "currency": "IQD",
        "city": "النجف",
        "condition": "ممتاز",
        "description": "آبل ووتش سيريز 9، 45 ملم، لون أسود مع سوار رياضي. مستخدمة شهرين فقط. كاملة بصندوقها وشاحنها.",
        "images": ["https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=600&h=400&fit=crop"],
    },
    {
        "title": "كاميرا كانون EOS R50",
        "category": "إلكترونيات",
        "subCategory": "كاميرات",
        "price": "550000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "كانون R50 ميرورلس، عدسة 18-45mm. مثالية للتصوير الفوتوغرافي والفيديو 4K. مع حقيبة وبطاريتين إضافيتين.",
        "images": ["https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600&h=400&fit=crop"],
    },

    # ─── أغراض البيت (12 إعلان) ───
    {
        "title": "غرفة نوم ماسترو كاملة",
        "category": "أغراض البيت",
        "subCategory": "أثاث وديكور",
        "price": "3500000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "ممتاز",
        "description": "طقم غرفة نوم ماسترو تركي: سرير كينج + خزانة 6 أبواب + تسريحة + طاولتين جانبيتين. خشب زان. لون بيج ذهبي. مستخدم 8 أشهر فقط.",
        "images": ["https://images.unsplash.com/photo-1505693314120-0d443867891c?w=600&h=400&fit=crop"],
    },
    {
        "title": "ثلاجة LG نوفروست 20 قدم",
        "category": "أغراض البيت",
        "subCategory": "أجهزة منزلية",
        "price": "850000",
        "currency": "IQD",
        "city": "الموصل",
        "condition": "جيد",
        "description": "ثلاجة LG نوفروست 20 قدم باب مزدوج. الفريزر فوق. شغالة بكفاءة. سبب البيع انتقالنا لبيت مجهز.",
        "images": ["https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=600&h=400&fit=crop"],
    },
    {
        "title": "غسالة سامسونج 9 كيلو",
        "category": "أغراض البيت",
        "subCategory": "أجهزة منزلية",
        "price": "450000",
        "currency": "IQD",
        "city": "البصرة",
        "condition": "جيد",
        "description": "غسالة سامسونج أوتوماتيك 9 كيلو. واجهة ديجيتال. مستخدمة سنة ونص. شغالة ممتاز بدون أي عطل.",
        "images": ["https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=600&h=400&fit=crop"],
    },
    {
        "title": "صالة جلوس 7 مقاعد",
        "category": "أغراض البيت",
        "subCategory": "أثاث وديكور",
        "price": "2200000",
        "currency": "IQD",
        "city": "كربلاء",
        "condition": "جيد",
        "description": "صالة جلوس 7 مقاعد جلد حقيقي، لون بني داكن. طقم متكامل: كنبة 3 + 2 + 2 + طاولة وسط. حالة ممتازة.",
        "images": ["https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&h=400&fit=crop"],
    },
    {
        "title": "مكيف سبليت كاريير 2.5 طن",
        "category": "أغراض البيت",
        "subCategory": "أجهزة منزلية",
        "price": "380000",
        "currency": "IQD",
        "city": "ذي قار",
        "condition": "جيد",
        "description": "مكيف كاريير 2.5 طن انفرتر. اشتري بـ 650 ألف. شغال مو معطوب. يكفي غرفة كبيرة 25 متر.",
        "images": ["https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=600&h=400&fit=crop"],
    },
    {
        "title": "مطبخ خشب MDF كامل",
        "category": "أغراض البيت",
        "subCategory": "أثاث وديكور",
        "price": "4500000",
        "currency": "IQD",
        "city": "أربيل",
        "condition": "ممتاز",
        "description": "مطبخ MDF تركي عالي الجودة. 4 متر طول + حمال فوق. مع غسالة صحون وطباخ 5 شعلة إيطالي. لون رمادي أنيق.",
        "images": ["https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=400&fit=crop"],
    },

    # ─── ملابس وأزياء (10 إعلان) ───
    {
        "title": "عباءة خليجية فاخرة",
        "category": "ملابس",
        "subCategory": "ملابس نسائية",
        "price": "85000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "عباءة خليجية قماش جورجيت عالي الجودة، مطرزة بالخيوط الذهبية. مقاس L. لبست مرة واحدة في حفل. مع علبتها الأصلية.",
        "images": ["https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600&h=400&fit=crop"],
    },
    {
        "title": "بدلة رجالية إيطالية",
        "category": "ملابس",
        "subCategory": "ملابس رجالية",
        "price": "180000",
        "currency": "IQD",
        "city": "الموصل",
        "condition": "ممتاز",
        "description": "بدلة رجالية قماش إيطالي slim fit، لون كحلي. مقاس 50. مع قميص وكرافة. مشتراة من إسطنبول. لبست مرتين.",
        "images": ["https://images.unsplash.com/photo-1594938298603-c8148c4b4d6f?w=600&h=400&fit=crop"],
    },
    {
        "title": "حذاء نايك Air Max الأصلي",
        "category": "ملابس",
        "subCategory": "أحذية",
        "price": "120000",
        "currency": "IQD",
        "city": "البصرة",
        "condition": "جيد",
        "description": "حذاء نايك Air Max 270 أصلي أمريكي. مقاس 43. لون أبيض/أسود. استخدام خفيف. كاملة بصندوقها الأصلي.",
        "images": ["https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&h=400&fit=crop"],
    },
    {
        "title": "شنطة لويس فيتون أصلية",
        "category": "ملابس",
        "subCategory": "حقائب نسائية",
        "price": "450000",
        "currency": "IQD",
        "city": "أربيل",
        "condition": "ممتاز",
        "description": "حقيبة لويس فيتون Neverfull MM أصلية. مشتراة من دبي مع الفاتورة والكيس. حالة ممتازة لا فيها أي تشقيق.",
        "images": ["https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=600&h=400&fit=crop"],
    },

    # ─── مواد بناء وتجهيزات (10 إعلان) ───
    {
        "title": "طابوق بلدي الفيصلية للبيع",
        "category": "مواد بناء",
        "subCategory": "طابوق وبلوك",
        "price": "280000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "20 ألف طابوق بلدي درجة أولى الفيصلية. متوفر بالكميات. التوصيل متاح داخل بغداد. السعر للألف 14 ألف دينار.",
        "images": ["https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&h=400&fit=crop"],
    },
    {
        "title": "حديد مسلح للبيع - مختلف المقاسات",
        "category": "مواد بناء",
        "subCategory": "حديد ومعادن",
        "price": "1200000",
        "currency": "IQD",
        "city": "كركوك",
        "condition": "جيد",
        "description": "10 طن حديد مسلح مقاسات 10، 12، 16 ملم. بقايا مشروع. بسعر السوق أو أقل شوية. الاستلام من الموقع.",
        "images": ["https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&h=400&fit=crop"],
    },
    {
        "title": "بويا كيلو للبيع - ألوان متنوعة",
        "category": "مواد بناء",
        "subCategory": "دهانات",
        "price": "15000",
        "currency": "IQD",
        "city": "البصرة",
        "condition": "جيد",
        "description": "بويا جدران داخلية كيلو، ألوان متنوعة. 50 كيلو متوفرة. بقايا بناء بيت. نوع جيد أبيض وألوان.",
        "images": ["https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=600&h=400&fit=crop"],
    },
    {
        "title": "بلاط سيراميك إيطالي - 60x60",
        "category": "مواد بناء",
        "subCategory": "سيراميك وبلاط",
        "price": "35000",
        "currency": "IQD",
        "city": "النجف",
        "condition": "ممتاز",
        "description": "بلاط سيراميك إيطالي 60x60 درجة أولى. 80 متر مربع متوفر. لون بيج فاتح لامع. بسعر مخفض لوجود فائض.",
        "images": ["https://images.unsplash.com/photo-1584622781867-1c5fe959a77e?w=600&h=400&fit=crop"],
    },

    # ─── خدمات وأعمال (10 إعلان) ───
    {
        "title": "مصمم غرافيك - شعارات وهويات بصرية",
        "category": "خدمات",
        "subCategory": "تصميم",
        "price": "50000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "مصمم جرافيك محترف خبرة 5 سنوات. تصميم شعارات، هويات بصرية، منيو، بنرات إعلانية. التسليم خلال 3 أيام. تعديلات غير محدودة.",
        "images": ["https://images.unsplash.com/photo-1626785774573-4b799315345d?w=600&h=400&fit=crop"],
    },
    {
        "title": "دروس خصوصية رياضيات - ثانوية وجامعة",
        "category": "خدمات",
        "subCategory": "تعليم ودروس",
        "price": "20000",
        "currency": "IQD",
        "city": "الموصل",
        "condition": "جيد",
        "description": "أستاذ رياضيات خبرة 10 سنوات. دروس خصوصية في البيت أو عن بعد. الساعة 20 ألف دينار. نسبة نجاح 95%.",
        "images": ["https://images.unsplash.com/photo-1509062522246-3755977927d7?w=600&h=400&fit=crop"],
    },
    {
        "title": "صالون حلاقة للرجال - تأجير كرسي",
        "category": "خدمات",
        "subCategory": "تأجير وأعمال",
        "price": "250000",
        "currency": "IQD",
        "city": "كربلاء",
        "condition": "جيد",
        "description": "كرسي للإيجار في صالون راقي بكربلاء المركز. موقع حيوي. الإيجار شهري شامل الماء والكهرباء والانترنت. الاستفسار جدي فقط.",
        "images": ["https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&h=400&fit=crop"],
    },
    {
        "title": "طباخة وخدمة منازل",
        "category": "خدمات",
        "subCategory": "خدمات منزلية",
        "price": "150000",
        "currency": "IQD",
        "city": "البصرة",
        "condition": "جيد",
        "description": "سيدة خبرة في الطبخ العراقي والعربي. متاحة للعمل في المنازل والأفراح والمناسبات. يومي أو بالمناسبة. معها شهادة صحية.",
        "images": ["https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=400&fit=crop"],
    },

    # ─── إضافية متنوعة (14 إعلان لإكمال الـ 100) ───
    {
        "title": "دراجة نارية هوندا 150cc 2022",
        "category": "سيارات",
        "subCategory": "دراجات نارية",
        "price": "3200000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "هوندا 150cc موديل 2022. لون أحمر/أسود. ماشية 12 ألف كم. وثائقها سليمة. شغالة ممتاز. البيع لشراء سيارة.",
        "images": ["https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=400&fit=crop"],
    },
    {
        "title": "عجل هولشتاين للبيع",
        "category": "حيوانات",
        "subCategory": "مواشي",
        "price": "2500000",
        "currency": "IQD",
        "city": "ديالى",
        "condition": "جيد",
        "description": "عجل هولشتاين عمره سنة ونص. وزن تقريبي 250 كيلو. صحي ومطعوم. مناسب للعيد. السعر قابل للتفاوض.",
        "images": ["https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=600&h=400&fit=crop"],
    },
    {
        "title": "كتب جامعية - هندسة مدنية",
        "category": "كتب وتعليم",
        "subCategory": "كتب جامعية",
        "price": "75000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "25 كتاب هندسة مدنية - تخرجت ومو محتاجها. منها: ميكانيكا التربة، الإنشاءات الخرسانية، الجسور. حالة جيدة.",
        "images": ["https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=600&h=400&fit=crop"],
    },
    {
        "title": "عود فارسي عتيق - للهواة",
        "category": "موسيقى",
        "subCategory": "آلات موسيقية",
        "price": "450000",
        "currency": "IQD",
        "city": "أربيل",
        "condition": "جيد",
        "description": "عود فارسي قديم صنع إيراني عمره 30+ سنة. صوت عميق ودافئ. مناسب للعازفين الجادين. مع حقيبة جلدية.",
        "images": ["https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=600&h=400&fit=crop"],
    },
    {
        "title": "جرو جولدن ريتريفر للبيع",
        "category": "حيوانات",
        "subCategory": "كلاب",
        "price": "350000",
        "currency": "IQD",
        "city": "أربيل",
        "condition": "ممتاز",
        "description": "جرو جولدن ريتريفر عمره 45 يوم. والديه بالبيت. مطعوم كامل. لون ذهبي فاتح. معه شهادة ولادة.",
        "images": ["https://images.unsplash.com/photo-1552053831-71594a27632d?w=600&h=400&fit=crop"],
    },
    {
        "title": "بيسكل كهربائي للبيع",
        "category": "رياضة",
        "subCategory": "دراجات هوائية",
        "price": "650000",
        "currency": "IQD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "دراجة كهربائية 48V 500W. تمشي 40 كم/ساعة. شحن 6 ساعات. عمر البطارية 35-40 كم. مستخدمة 6 أشهر.",
        "images": ["https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600&h=400&fit=crop"],
    },
    {
        "title": "مطعم للبيع - موقع حيوي",
        "category": "أعمال وشركات",
        "subCategory": "مطاعم وكافيهات",
        "price": "45000",
        "currency": "USD",
        "city": "كربلاء",
        "condition": "جيد",
        "description": "مطعم مشاوي شغال منذ 5 سنوات. يسع 60 شخص. مع كامل التجهيزات والزبائن الدائمين. البيع للهجرة. دخل شهري ثابت.",
        "images": ["https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&h=400&fit=crop"],
    },
    {
        "title": "بستان نخيل للإيجار السنوي",
        "category": "زراعة",
        "subCategory": "بساتين وأراضي زراعية",
        "price": "5000000",
        "currency": "IQD",
        "city": "ذي قار",
        "condition": "جيد",
        "description": "بستان نخيل 2 دونم، 80 نخلة. مياه وفيرة. إيجار سنوي. المحصول للمستأجر. قرب مدينة الناصرية.",
        "images": ["https://images.unsplash.com/photo-1504109586057-7a2ae83d1338?w=600&h=400&fit=crop"],
    },
    {
        "title": "معدات صالة رياضية - بالكامل",
        "category": "رياضة",
        "subCategory": "معدات رياضية",
        "price": "12000",
        "currency": "USD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "كامل معدات صالة رياضية: أجهزة كارديو، أوزان، بنش، كابل. مستخدمة سنتين. مناسبة لفتح صالة جديدة.",
        "images": ["https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&h=400&fit=crop"],
    },
    {
        "title": "شاحنة نقل مان 2018",
        "category": "سيارات",
        "subCategory": "شاحنات ومركبات",
        "price": "28000",
        "currency": "USD",
        "city": "البصرة",
        "condition": "جيد",
        "description": "شاحنة MAN نقل عام 2018. حمولة 12 طن. موتور ممتاز. مسجلة ومختبرة. تعمل بالشحنات بين المحافظات.",
        "images": ["https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=600&h=400&fit=crop"],
    },
    {
        "title": "جهاز طحن قهوة احترافي",
        "category": "مطاعم وكافيهات",
        "subCategory": "معدات مطاعم",
        "price": "750000",
        "currency": "IQD",
        "city": "أربيل",
        "condition": "جيد",
        "description": "طاحونة قهوة إيطالية Mazzer Mini احترافية. للكافيهات والمطاعم. صيانة دورية. سبب البيع: تغيير الطراز.",
        "images": ["https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&h=400&fit=crop"],
    },
    {
        "title": "طقم فضة أنتيك",
        "category": "تحف وقطع نادرة",
        "subCategory": "مقتنيات",
        "price": "1800000",
        "currency": "IQD",
        "city": "الموصل",
        "condition": "ممتاز",
        "description": "طقم فضة عراقي قديم: إبريق + كوب + صحن + ملاعق 6 حبة. زين ومنقوش. وزن 800 غرام. إرث عائلي.",
        "images": ["https://images.unsplash.com/photo-1547310838-c003e74d2e5e?w=600&h=400&fit=crop"],
    },
    {
        "title": "عمارة تجارية بالأنبار",
        "category": "عقارات",
        "subCategory": "عقارات تجارية",
        "price": "185000",
        "currency": "USD",
        "city": "الأنبار",
        "condition": "جيد",
        "description": "عمارة تجارية 5 طوابق وسط الرمادي. الطابق السفلي تجاري والباقي شقق. دخل شهري ممتاز. طابو صرف.",
        "images": ["https://images.unsplash.com/photo-1486325212027-8081e485255e?w=600&h=400&fit=crop"],
    },
    {
        "title": "جهاز سونار طبي للبيع",
        "category": "معدات طبية",
        "subCategory": "أجهزة طبية",
        "price": "8500",
        "currency": "USD",
        "city": "بغداد",
        "condition": "جيد",
        "description": "جهاز سونار Samsung طبي 2019. مع مجسات متعددة. معه ضمان الشركة. مناسب لعيادة أو مستوصف. للتواصل الجادين فقط.",
        "images": ["https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600&h=400&fit=crop"],
    },
]

# ─── أرقام هاتف عراقية وهمية ────────────────────────────────────
def random_phone():
    prefix = random.choice(["077", "078", "079", "075", "076"])
    suffix = "".join([str(random.randint(0, 9)) for _ in range(8)])
    return f"{prefix}{suffix}"

# ─── رفع الإعلانات ───────────────────────────────────────────────
def upload_ads():
    print("🚀 بدء رفع الإعلانات إلى Firestore...")
    
    all_names = MALE_NAMES + FEMALE_NAMES
    collection = db.collection("ads")
    count = 0
    base_time = datetime.now()

    # سنكرر الإعلانات بتعديلات طفيفة للوصول إلى 100
    for i in range(100):
        ad_template = ADS_DATA[i % len(ADS_DATA)]
        ad = dict(ad_template)  # نسخة

        # اختيار المالك
        is_female = random.random() < 0.4
        name = random.choice(FEMALE_NAMES if is_female else MALE_NAMES)
        avatar = random.choice(FEMALE_AVATARS if is_female else MALE_AVATARS)

        # تعديل السعر قليلاً لكل نسخة
        try:
            base_price = int(ad["price"])
            factor = random.uniform(0.85, 1.15)
            ad["price"] = str(int(base_price * factor))
        except Exception:
            pass

        # تعديل المدينة عشوائياً أحياناً
        if random.random() < 0.3:
            ad["city"] = random.choice(CITIES)

        # بيانات الإعلان النهائية
        doc = {
            "title": ad["title"],
            "description": ad["description"],
            "category": ad["category"],
            "subCategory": ad.get("subCategory", ""),
            "price": ad["price"],
            "currency": ad.get("currency", "IQD"),
            "city": ad["city"],
            "condition": ad.get("condition", "جيد"),
            "images": ad.get("images", []),
            "phone": random_phone(),
            "sellerName": name,
            "sellerAvatar": avatar,
            "isFeatured": random.random() < 0.15,
            "views": random.randint(5, 350),
            "favorites": random.randint(0, 40),
            "isActive": True,
            "isDemo": True,
            "createdAt": firestore.SERVER_TIMESTAMP,
            "updatedAt": firestore.SERVER_TIMESTAMP,
        }

        collection.add(doc)
        count += 1
        print(f"  ✅ [{count:03d}/100] {doc['title']} — {doc['city']} — {doc['price']} {doc['currency']}")

    print(f"\n🎉 تم رفع {count} إعلان بنجاح!")
    print("📱 افتح التطبيق وستجد الإعلانات في الصفحة الرئيسية")

if __name__ == "__main__":
    upload_ads()
