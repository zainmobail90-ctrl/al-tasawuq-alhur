# الإشعارات الفورية

تمت إضافة Firebase Cloud Messaging (FCM) لحفظ Token الخاص بكل مستخدم داخل:
`users/{uid}`

## ما يحتاجه المشروع حتى تصبح الإشعارات تلقائية بالكامل
تحتاج Cloud Function في Firebase تراقب تغييرات `orders` وترسل إشعاراً:
- عند إنشاء طلب جديد → إلى السائق المسند.
- عند قبول/تغيير الحالة → إلى الزبون.
- عند التسليم أو الإلغاء → إلى الزبون.

الكود الحالي يسجل FCM Token من التطبيق ويحدّثه عند تغييره.

## Android
أضف ملف `google-services.json` الناتج من Firebase إلى:
`android/app/google-services.json`
ثم نفّذ `flutterfire configure`.

## iPhone
أضف `GoogleService-Info.plist` إلى مشروع iOS، وفعّل Push Notifications وBackground Modes في Xcode، ثم نفّذ إعداد Firebase.

## ملاحظة
الإشعار الخلفي يحتاج خادم/Cloud Function لإرسال الرسائل؛ لا نضع مفاتيح FCM السرية داخل التطبيق.
