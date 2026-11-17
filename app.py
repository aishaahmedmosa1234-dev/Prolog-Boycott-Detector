import os
import shutil
from concurrent.futures import ThreadPoolExecutor

import streamlit as st
from pyswip import Prolog

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
IMAGES_DIR = os.path.join(BASE_DIR, "images")
PL_FILE = os.path.join(BASE_DIR, "boycott.pl").replace("\\", "/")
PRODUCTS_PL_FILE = os.path.join(BASE_DIR, "products.pl")


# ------------------------------------------------------------
#  Prolog bridge
# ------------------------------------------------------------
class PrologBridge:
    def __init__(self, path):
        self._pool = ThreadPoolExecutor(max_workers=1)
        self._prolog = self._pool.submit(self._init, path).result()

    @staticmethod
    def _init(path):
        prolog = Prolog()
        prolog.consult(path)
        return prolog

    def query(self, q):
        return self._pool.submit(lambda: list(self._prolog.query(q))).result()


@st.cache_resource
def get_bridge():
    return PrologBridge(PL_FILE)


bridge = get_bridge()


# ------------------------------------------------------------
#  Helpers
# ------------------------------------------------------------
@st.cache_data
def load_products():
    rows = bridge.query("product(P, N, C)")
    return [(str(r["P"]), str(r["N"]), str(r["C"])) for r in rows]


def check_product(pid):
    rows = bridge.query(f"check_product({pid}, S, A, I)")
    if not rows:
        return "unknown", [], "no_image.png"
    r = rows[0]
    alts = [str(a) for a in r["A"]]
    return str(r["S"]), alts, str(r["I"])


def product_info(pid):
    name_res = bridge.query(f"display_name({pid}, N)")
    img_res = bridge.query(f"image_of({pid}, F)")
    name = str(name_res[0]["N"]) if name_res else pid
    img = str(img_res[0]["F"]) if img_res else "no_image.png"
    return name, img


def image_path(filename):
    path = os.path.join(IMAGES_DIR, filename)
    if not os.path.exists(path):
        path = os.path.join(IMAGES_DIR, "no_image.png")
    return path


# ------------------------------------------------------------
#  UI Setup & Sidebar (Role Selection)
# ------------------------------------------------------------
st.set_page_config(page_title="Boycott Checker System", page_icon="🛒", layout="centered")

st.sidebar.title("🔐 System Mode")
role = st.sidebar.radio("Select Your Role:", ["User (Search & Alternatives)", "Admin (Manage Database)"])

products = load_products()
names = {pid: name for pid, name, _ in products}
categories = sorted({cat for _, _, cat in products})

# ============================================================
#  USER MODE (بحث + معرفة المقاطعة + البدائل المتاحة)
# ============================================================
if role == "User (Search & Alternatives)":
    st.title("🛒 Boycott Product Checker - User Portal")
    st.write("Search for any product to check if it is boycotted and view available safe alternatives.")

    category = st.selectbox("Filter by Category", ["all"] + categories)
    options = [pid for pid, _, cat in products if category == "all" or cat == category]

    selected = st.selectbox(
        "Select or Search Product",
        options,
        index=None,
        placeholder="Choose a product...",
        format_func=lambda pid: names[pid],
    )

    if st.button("Check Product", type="primary", disabled=selected is None):
        status, alts, img = check_product(selected)
        name = names[selected]

        if status == "boycotted":
            st.error(f"⚠️ **{name}** is on the boycott list!")
            st.image(image_path(img), width=200)

            if alts:
                st.subheader("🟢 Safe Alternatives Available:")
                cols = st.columns(len(alts) if len(alts) <= 4 else 4)
                for i, alt in enumerate(alts):
                    alt_name, alt_img = product_info(alt)
                    with cols[i % len(cols)]:
                        st.image(image_path(alt_img), caption=alt_name, width=130)
            else:
                st.info("No alternatives are currently available for this product.")

        elif status == "safe":
            st.success(f"✅ **{name}** is NOT boycotted (Safe to use).")
            st.image(image_path(img), width=220)

        else:
            st.warning("This product is not found in the database.")

# ============================================================
#  ADMIN MODE (إضافة منتجات، ربط بدائل، رفع صور، وحذف منتجات)
# ============================================================
else:
    st.title("🛠️ Admin Dashboard - Manage Products")
    st.write("Add new products, set boycott status, link alternatives, upload images, or delete products.")

    admin_action = st.selectbox(
        "Choose Admin Action", 
        ["Add New Product", "Link Alternative to Boycotted Product", "Delete Product"]
    )

    # 1. إضافة منتج جديد
    if admin_action == "Add New Product":
        st.subheader("➕ Add a New Product")
        new_id = st.text_input("Product ID (e.g. brand_name, no spaces):").strip().lower()
        new_name = st.text_input("Display Name (e.g. Brand Name):")
        new_category = st.selectbox("Category", categories if categories else ["food", "drinks", "cleaning", "clothes"])
        is_boycott_check = st.checkbox("Is this product boycotted?")
        
        uploaded_image = st.file_uploader("Upload Product Image (PNG/JPG)", type=["png", "jpg", "jpeg"])
        
        if st.button("Save Product to Database", type="primary"):
            if new_id and new_name:
                img_filename = "no_image.png"
                if uploaded_image is not None:
                    os.makedirs(IMAGES_DIR, exist_ok=True)
                    img_filename = f"{new_id}.png"
                    with open(os.path.join(IMAGES_DIR, img_filename), "wb") as f:
                        f.write(uploaded_image.getbuffer())

                boycotted_bool = "true" if is_boycott_check else "false"
                q = f"add_product_to_db({new_id}, '{new_name}', {new_category}, {boycotted_bool}, {img_filename})"
                try:
                    bridge.query(q)
                    st.cache_data.clear()
                    st.cache_resource.clear()
                    st.success(f"✅ Successfully added **{new_name}** to the database! Refresh to see changes.")
                except Exception as e:
                    st.error(f"Error executing prolog rule: {e}")
            else:
                st.warning("Please fill in both Product ID and Display Name.")

    # 2. ربط بديل بمنتج مقاطع
    elif admin_action == "Link Alternative to Boycotted Product":
        st.subheader("🔗 Link Alternative to a Boycotted Product")
        boycotted_pids = [pid for pid, _, _ in products if bridge.query(f"is_boycotted({pid})")]
        
        if boycotted_pids:
            target_boycotted = st.selectbox(
                "Select Boycotted Product", 
                boycotted_pids, 
                format_func=lambda pid: names.get(pid, pid)
            )
            alt_id = st.selectbox(
                "Select Safe Product as Alternative", 
                [pid for pid, _, _ in products], 
                format_func=lambda pid: names.get(pid, pid),
                key="alt_select"
            )
            
            if st.button("Save Alternative Link", type="primary"):
                if target_boycotted and alt_id:
                    q = f"add_alternative_to_db({target_boycotted}, {alt_id})"
                    try:
                        open(PRODUCTS_PL_FILE, 'a').write(f"alternative({target_boycotted}, {alt_id}).\n")
                        st.cache_data.clear()
                        st.cache_resource.clear()
                        st.success(f"✅ Successfully linked alternative!")
                    except Exception as e:
                        st.error(f"Error: {e}")
        else:
            st.warning("No boycotted products available.")

    # 3. حذف منتج
    elif admin_action == "Delete Product":
        st.subheader("🗑️ Delete a Product from Database")
        product_to_delete = st.selectbox(
            "Select Product to Delete", 
            [pid for pid, _, _ in products], 
            format_func=lambda pid: names.get(pid, pid)
        )
        
        if st.button("Delete Selected Product", type="primary"):
            if product_to_delete:
                try:
                    # إعادة كتابة ملف products.pl بدون هذا المنتج أو الحقائق الخاصة به
                    with open(PRODUCTS_PL_FILE, "r", encoding="utf-8") as f:
                        lines = f.readlines()
                    
                    new_lines = []
                    skip = False
                    for line in lines:
                        if product_to_delete in line:
                            continue  # تخطي أي سطر يخص المنتج المحذوف
                        new_lines.append(line)
                        
                    with open(PRODUCTS_PL_FILE, "w", encoding="utf-8") as f:
                        f.writelines(new_lines)
                        
                    st.cache_data.clear()
                    st.cache_resource.clear()
                    st.success(f"✅ Product **{names.get(product_to_delete, product_to_delete)}** has been deleted successfully! Please restart/refresh.")
                except Exception as e:
                    st.error(f"Error deleting product: {e}")
# ```[cite: 1]

# ---

# ### مميزات التحديث الجديد:
# 1. **صلاحيات الـ User:** واجهة نظيفة ومباشرة تتيح له اختيار أي منتج لمعرفة حالته (مقاطع أم آمن) مع عرض صورته والبدائل المتاحة بشكل جمالي[cite: 1].
# 2. **صلاحيات الـ Admin:**
#    * **إضافة منتج:** تحديد الـ ID، الاسم، التصنيف، الحالة (مقاطع أم لا)، مع إمكانية **رفع صورة حقيقية** للمنتج من جهازه وحفظها تلقائياً في مجلد `images/`.
#    * **ربط البدائل:** اختيار المنتج المقاطع من قائمة المنتجات المقاطعة فقط وربطه ببديل آمن[cite: 1].
#    * **حذف المنتج:** إمكانية حذف أي منتج نهائياً من قاعدة البيانات بكل سهولة.
# 3. **التحديث الفوري:** استخدام `st.cache_data.clear()` لتحديث واجهة التطبيق وقواعد البيانات فوراً عند أي تعديل يقوم به الأدمن.