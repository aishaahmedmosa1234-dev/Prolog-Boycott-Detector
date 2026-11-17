%% ============================================================
%%  boycott.pl  -  Rules - Boycott Product Checker
%%  Loads the knowledge base from products.pl
%% ============================================================

:- ensure_loaded('products.pl').

%% ------------------------------------------------------------
%%  Basic rules
%% ------------------------------------------------------------

% A product is boycotted if there is a boycotted/1 fact for it.
is_boycotted(P) :-
    product(P, _, _),
    boycotted(P).

% A product is safe if it exists in the database and is NOT boycotted
% (negation as failure).
is_safe(P) :-
    product(P, _, _),
    \+ boycotted(P).

% Product id exists in the database.
known_product(P) :-
    product(P, _, _).

%% ------------------------------------------------------------
%%  Alternatives
%% ------------------------------------------------------------

% safe_alternatives(+P, -List)
% All NOT boycotted alternatives of P (no duplicates).
safe_alternatives(P, List) :-
    findall(A, (alternative(P, A), is_safe(A)), Raw),
    list_to_set(Raw, List).

%% ------------------------------------------------------------
%%  Images
%% ------------------------------------------------------------

% image_of(+P, -File): image file of P, or the default image.
image_of(P, File) :-
    image(P, File), !.
image_of(_, 'no_image.png').

%% ------------------------------------------------------------
%%  Main rule called by the GUI
%% ------------------------------------------------------------

% check_product(+P, -Status, -Alts, -Img)
%   Status = boycotted | safe | unknown
%   Alts   = list of safe alternatives (empty unless boycotted)
%   Img    = image file name

check_product(P, unknown, [], 'no_image.png') :-
    \+ known_product(P), !.

check_product(P, boycotted, Alts, Img) :-
    is_boycotted(P), !,
    safe_alternatives(P, Alts),
    image_of(P, Img).

check_product(P, safe, [], Img) :-
    is_safe(P),
    image_of(P, Img).

%% ------------------------------------------------------------
%%  Helpers for the GUI (lists and names)
%% ------------------------------------------------------------

% display_name(+Id, -Name)
display_name(P, Name) :-
    product(P, Name, _).

% all_products(-List): list of Id-Name-Category
all_products(List) :-
    findall(P-N-C, product(P, N, C), List).

% products_in(+Category, -List): list of Id-Name
products_in(Category, List) :-
    findall(P-N, product(P, N, Category), List).

% find_by_name(+Name, -Id): look up a product id from its display name
find_by_name(Name, P) :-
    product(P, Name, _), !.

%% ------------------------------------------------------------
%%  إضافات المنهج والدوال المطلوبة (Matching, Length, Member, Append, Conc, Del, Subset)
%% ------------------------------------------------------------

% 1. جزء المطابقة (Matching) باستخدام علامة التساوي (=) ومقارنة البنية
matching_product(ProductCategoryPair, Category) :-
    ProductCategoryPair = product(P, _, Category),
    is_boycotted(P).

% 2. دالة length لحساب عدد المنتجات البديلة
alternative_count(P, Count) :-
    safe_alternatives(P, Alts),
    length(Alts, Count).

% 3. دالة member للتحقق من وجود منتج داخل القائمة
is_member(X, [X|_]).
is_member(X, [_|Tail]) :-
    is_member(X, Tail).

% قاعدة مساعدة للتحقق هل المنتج بديل لمنتج مقاطع
is_member_alternative(Alt, P) :-
    safe_alternatives(P, Alts),
    is_member(Alt, Alts).

% 4. دالة append لدمج قائمتين
merge_lists(List1, List2, CombinedList) :-
    append(List1, List2, CombinedList).

% 5. دالة conc لدمج قائمتين (Concatenation - تعريف المنهج)
conc([], L, L).
conc([X|L1], L2, [X|L3]) :-
    conc(L1, L2, L3).

% مثال تطبيقي لاستخدام conc لدمج بدائل منتجين مقاطعين معاً:
combine_two_alternatives(P1, P2, AllAlts) :-
    safe_alternatives(P1, Alts1),
    safe_alternatives(P2, Alts2),
    conc(Alts1, Alts2, AllAlts).

% 6. دالة الحذف del لحذف عنصر من القائمة
del(X, [X|Tail], Tail).
del(X, [Y|Tail], [Y|Tail1]) :-
    del(X, Tail, Tail1).

% 7. دالة subset لعرض مجموعات فرعية أو اقتراحات من البدائل المتاحة
my_subset([], _).
my_subset([X|Tail], Set) :-
    is_member(X, Set),
    my_subset(Tail, Set).

% قاعدة لاستخراج مجموعة فرعية غير فارغة من البدائل المتاحة
alternatives_subset(P, Sub) :-
    safe_alternatives(P, Alts),
    my_subset(Sub, Alts),
    Sub \= [].

%% ------------------------------------------------------------
%%  إضافات صلاحيات الـ Admin (إضافة منتجات وبدائل لقاعدة البيانات)
%% ------------------------------------------------------------

% قاعدة لإضافة منتج جديد وحفظه في products.pl
add_product_to_db(Id, Name, Category, IsBoycotted, ImgFile) :-
    open('products.pl', append, Stream),
    format(Stream, "product(~w, '~w', ~w).~n", [Id, Name, Category]),
    (IsBoycotted == true ->
        format(Stream, "boycotted(~w).~n", [Id])
    ;   true
    ),
    format(Stream, "image(~w, '~w').~n~n", [Id, ImgFile]),
    close(Stream).

% قاعدة لإضافة بديل لمنتج مقاطع وحفظه
add_alternative_to_db(BoycottedId, AltId) :-
    open('products.pl', append, Stream),
    format(Stream, "alternative(~w, ~w).~n", [BoycottedId, AltId]),
    close(Stream).

%% ------------------------------------------------------------
%%  Data sanity checks (for testing only)
%% ------------------------------------------------------------

bad_alternative(P, A) :-
    alternative(P, A),
    ( \+ known_product(A) ; boycotted(A) ).

no_alternative(P) :-
    is_boycotted(P),
    safe_alternatives(P, []).

missing_image(P) :-
    product(P, _, _),
    \+ image(P, _).
