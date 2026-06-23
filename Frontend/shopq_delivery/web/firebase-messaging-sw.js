importScripts(
  "https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js",
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js",
);

firebase.initializeApp({
  apiKey: "AIzaSyB7T6JFb6D9SdxVRFtYC4bRznufq4d-Sy8",
  authDomain: "shopq-multi-vendor.firebaseapp.com",
  projectId: "shopq-multi-vendor",
  storageBucket: "shopq-multi-vendor.firebasestorage.app",
  messagingSenderId: "411644656998",
  appId: "1:411644656998:web:ff4cac4e49a05a844d9ca7"
});

const messaging = firebase.messaging();
