importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

// Replace with your Firebase config
firebase.initializeApp({
apiKey: "AIzaSyC3AH2PTFWmeGkAosaz18omPWEhIgkKJ98",
authDomain: "pharmacy-a8915.firebaseapp.com",
projectId: "pharmacy-a8915",
storageBucket: "pharmacy-a8915.firebasestorage.app",
messagingSenderId: "90363222372",
appId: "1:90363222372:web:b1601dca815c82beb80271",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
console.log("Received background message ", payload);
const notificationTitle = payload.notification.title;
const notificationOptions = {
body: payload.notification.body,
icon: "/icons/icon-192x192.png",
};
self.registration.showNotification(notificationTitle, notificationOptions);
});
