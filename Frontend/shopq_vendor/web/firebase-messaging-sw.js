importScripts(
  "https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js",
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js",
);

firebase.initializeApp({
  apiKey: "AIzaSyB7T6JFb6D9SdxVRFtYC4bRznufq4d-Sy8",
  appId: "1:411644656998:web:ff4cac4e49a05a844d9ca7",
  messagingSenderId: "411644656998",
  projectId: "shopq-multi-vendor",
  authDomain: "shopq-multi-vendor.firebaseapp.com",
  storageBucket: "shopq-multi-vendor.firebasestorage.app",
});

const messaging = firebase.messaging();
