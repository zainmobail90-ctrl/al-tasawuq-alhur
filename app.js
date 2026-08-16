import { initializeApp } from "https://www.gstatic.com/firebasejs/11.9.1/firebase-app.js";
import { getAuth, signInWithEmailAndPassword, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/11.9.1/firebase-auth.js";
import { getFirestore, collection, query, orderBy, onSnapshot, doc, updateDoc, getDocs, where } from "https://www.gstatic.com/firebasejs/11.9.1/firebase-firestore.js";

/*
  ضع إعدادات مشروع Firebase هنا.
  تحصل عليها من Firebase Console > Project settings > Your apps > Web app.
*/
const firebaseConfig = {
  apiKey: "PUT_YOUR_API_KEY",
  authDomain: "PUT_YOUR_PROJECT.firebaseapp.com",
  projectId: "PUT_YOUR_PROJECT_ID",
  storageBucket: "PUT_YOUR_PROJECT.appspot.com",
  messagingSenderId: "PUT_YOUR_SENDER_ID",
  appId: "PUT_YOUR_APP_ID"
};

const firebaseApp = initializeApp(firebaseConfig);
const auth = getAuth(firebaseApp);
const db = getFirestore(firebaseApp);

const $ = id => document.getElementById(id);
let orders = [];
let selectedId = null;

const statusNames = {
  new:"جديد", accepted:"تم قبول الطلب", shopping:"جاري شراء الطلب",
  delivering:"بالطريق", delivered:"تم التسليم", cancelled:"ملغي"
};

function money(v){ return Number(v||0).toLocaleString("ar-IQ")+" د.ع"; }

$("loginBtn").onclick = async () => {
  $("loginError").textContent = "";
  try {
    await signInWithEmailAndPassword(auth, $("email").value.trim(), $("password").value);
  } catch(e) {
    $("loginError").textContent = "فشل الدخول: تأكد من البريد وكلمة المرور.";
  }
};

$("logoutBtn").onclick = () => signOut(auth);

onAuthStateChanged(auth, user => {
  if(user){
    $("login").classList.add("hidden");
    $("app").classList.remove("hidden");
    $("adminEmail").textContent = user.email || "";
    startOrders();
  } else {
    $("login").classList.remove("hidden");
    $("app").classList.add("hidden");
  }
});

function startOrders(){
  const q = query(collection(db,"orders"), orderBy("createdAt","desc"));
  onSnapshot(q, snap => {
    orders = snap.docs.map(d => ({id:d.id,...d.data()}));
    renderDashboard();
    renderOrders();
    renderCustomers();
  });
}

function renderDashboard(){
  $("total").textContent = orders.length;
  $("new").textContent = orders.filter(x=>x.status==="new").length;
  $("active").textContent = orders.filter(x=>["accepted","shopping","delivering"].includes(x.status)).length;
  $("done").textContent = orders.filter(x=>x.status==="delivered").length;
  $("recent").innerHTML = orders.slice(0,8).map(orderRow).join("");
}

function orderRow(o){
  return `<div class="row">
    <div><b>#${o.id.slice(0,8)}</b><br>${escapeHtml(o.customerPhone||"")}</div>
    <div>${escapeHtml((o.requestText||"").slice(0,70))}</div>
    <div><span class="badge">${statusNames[o.status]||o.status}</span></div>
    <button class="action" data-id="${o.id}">تفاصيل</button>
  </div>`;
}

function renderOrders(){ $("ordersTable").innerHTML = orders.map(orderRow).join("") || "<p>لا توجد طلبات.</p>"; bindDetails(); }
function bindDetails(){ document.querySelectorAll("[data-id]").forEach(b=>b.onclick=()=>openOrder(b.dataset.id)); }

function renderCustomers(){
  const map = new Map();
  orders.forEach(o=>{
    const key=o.customerPhone||o.customerId||"غير معروف";
    if(!map.has(key)) map.set(key,0);
    map.set(key,map.get(key)+1);
  });
  $("customersTable").innerHTML = [...map.entries()].map(([phone,count])=>
    `<div class="row"><div><b>${escapeHtml(phone)}</b></div><div>عدد الطلبات: ${count}</div><div></div><div></div></div>`
  ).join("") || "<p>لا يوجد زبائن.</p>";
}

function openOrder(id){
  const o=orders.find(x=>x.id===id); if(!o) return;
  selectedId=id;
  $("orderDetails").innerHTML = `
    <div class="detail"><b>الطلب:</b> ${escapeHtml(o.requestText||"")}</div>
    <div class="detail"><b>العنوان:</b> ${escapeHtml(o.address||"")}</div>
    <div class="detail"><b>الملاحظات:</b> ${escapeHtml(o.notes||"لا توجد")}</div>
    <div class="detail"><b>الهاتف:</b> ${escapeHtml(o.customerPhone||"")}</div>
    <div class="detail"><b>الدفع:</b> ${o.paymentMethod==="cash"?"نقدي":"إلكتروني"}</div>
  `;
  $("goodsPrice").value=o.goodsPrice||"";
  $("deliveryFee").value=o.deliveryFee||"";
  $("status").value=o.status||"new";\n  const driverOptions = drivers.map(d=>`<option value="${d.id}" ${o.driverId===d.id?"selected":""}>${escapeHtml(d.name||d.phone||d.id)}</option>`).join("");\n  const driverBox = `<label>السائق</label><select id="driverId"><option value="">غير مسند</option>${driverOptions}</select>`;\n  $("orderDetails").insertAdjacentHTML("beforeend", driverBox);
  $("orderModal").classList.remove("hidden");
}

$("closeModal").onclick=()=>$("orderModal").classList.add("hidden");
$("saveOrder").onclick=async()=>{
  if(!selectedId) return;
  await updateDoc(doc(db,"orders",selectedId),{
    goodsPrice:Number($("goodsPrice").value||0),
    deliveryFee:Number($("deliveryFee").value||0),
    totalPrice:Number($("goodsPrice").value||0)+Number($("deliveryFee").value||0),
    status:$("status").value,
    updatedAt:new Date()
  });
  $("orderModal").classList.add("hidden");
};

document.querySelectorAll(".nav").forEach(btn=>{
  btn.onclick=()=>{
    document.querySelectorAll(".nav").forEach(x=>x.classList.remove("active"));
    btn.classList.add("active");
    document.querySelectorAll(".view").forEach(v=>v.classList.add("hidden"));
    $(btn.dataset.view).classList.remove("hidden");
    $("pageTitle").textContent={dashboard:"الرئيسية",orders:"الطلبات",customers:"الزبائن"}[btn.dataset.view];
  };
});

function escapeHtml(s){
  return String(s).replace(/[&<>"']/g,m=>({"&":"&amp;","<":"&lt;",">":"&gt;",""":"&quot;","'":"&#039;"}[m]));
}
