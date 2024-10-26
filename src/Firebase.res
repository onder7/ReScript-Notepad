type config = {
  apiKey: string,
  authDomain: string,
  projectId: string,
  storageBucket: string,
  messagingSenderId: string,
  appId: string,
}

@module("firebase/app") external initializeApp: config => unit = "initializeApp"
@module("firebase/firestore") external getFirestore: unit => 'a = "getFirestore"
@module("firebase/firestore") external collection: ('a, string) => 'b = "collection"
@module("firebase/firestore") external addDoc: ('b, 'c) => Promise.t<'d> = "addDoc"
@module("firebase/firestore") external getDocs: 'b => Promise.t<'e> = "getDocs"
@module("firebase/firestore") external deleteDoc: 'f => Promise.t<unit> = "deleteDoc"
@module("firebase/firestore") external doc: ('a, string, string) => 'f = "doc"

// Firebase console'dan aldığınız yapılandırmayı buraya ekleyin
let firebaseConfig = {
  apiKey: "AIzaSyA8EmnppuDuVXRPzONCdODhoDIO7-nJwNI",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
}

// Firebase'i başlat
initializeApp(firebaseConfig)

// Firestore veritabanı referansı
let db = getFirestore()