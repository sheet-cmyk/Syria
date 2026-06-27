importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDf6MYo4rB4fN2coCsbSYromCH0JEeeAas",
  authDomain: "syria2026.firebaseapp.com",
  projectId: "syria2026",
  storageBucket: "syria2026.firebasestorage.app",
  messagingSenderId: "1022310524811",
  appId: "1:1022310524811:web:ed18c6c5e8e02b5330b18e",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title ?? payload.data?.title ?? "سوق مستعمل سوريا";
  const body  = payload.notification?.body  ?? payload.data?.body  ?? "";
  self.registration.showNotification(title, {
    body,
    icon: "/icons/Icon-192.png",
  });
});
